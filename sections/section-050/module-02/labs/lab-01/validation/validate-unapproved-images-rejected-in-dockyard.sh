#!/usr/bin/env bash
# Check: pods with other registries, and look-alike prefixes, are rejected in dockyard.
set -uo pipefail

admit_pod() {
  # usage: admit_pod <namespace> <service-account> <image> [init-container-image]
  local ns="$1" sa="$2" image="$3" init_image="${4:-}"
  local init_block=""
  if [ -n "$init_image" ]; then
    init_block="  initContainers:
  - name: prepare
    image: ${init_image}
    command: [\"true\"]"
  fi
  kubectl create --dry-run=server -f - 2>&1 <<MANIFEST
apiVersion: v1
kind: Pod
metadata:
  name: grader-probe
  namespace: ${ns}
spec:
  serviceAccountName: ${sa}
  containers:
  - name: main
    image: ${image}
    command: ["true"]
${init_block}
MANIFEST
}

# Succeeds when the admission policy denies the pod. Retries because a new
# policy needs a few seconds before the API server enforces it.
expect_denied() {
  local out i
  for i in $(seq 1 10); do
    out="$(admit_pod "$@" || true)"
    if echo "$out" | grep -q "denied request"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

# Succeeds when the API server accepts the pod (server-side dry run).
expect_admitted() {
  admit_pod "$@" >/dev/null 2>&1
}
fail=0
for image in docker.io/library/busybox:1.37 registry.starfleet.example.attacker.test/fleet/hauler:2.4 ghcr.io/stefanprodan-evil/podinfo:6.15.0; do
  if ! expect_denied dockyard hauler "$image"; then
    echo "FAIL: a pod with image ${image} was not rejected in dockyard"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: unapproved and look-alike images are rejected in dockyard"
fi
exit "$fail"
