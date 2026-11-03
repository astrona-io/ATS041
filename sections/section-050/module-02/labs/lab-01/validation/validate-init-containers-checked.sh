#!/usr/bin/env bash
# Check: an unapproved init container is rejected even when the main container is approved.
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
if ! expect_denied dockyard hauler registry.starfleet.example/fleet/hauler:2.4 docker.io/library/busybox:1.37; then
  echo "FAIL: a pod with an approved container and an unapproved init container was not rejected"
  exit 1
fi
if ! expect_admitted dockyard hauler registry.starfleet.example/fleet/hauler:2.4 ghcr.io/stefanprodan/podinfo:6.15.0; then
  echo "FAIL: a pod with an approved init container was not admitted"
  exit 1
fi
echo "PASS: init containers are checked"
