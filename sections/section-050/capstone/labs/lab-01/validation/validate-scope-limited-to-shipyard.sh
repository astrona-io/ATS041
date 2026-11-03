#!/usr/bin/env bash
# Check: tag-only pods are still admitted in outpost and kube-system.
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
if ! expect_admitted outpost drifter ghcr.io/stefanprodan/podinfo:6.15.0; then
  echo "FAIL: a tag-only pod was not admitted in outpost"
  fail=1
fi
if ! expect_admitted kube-system default ghcr.io/stefanprodan/podinfo:6.15.0; then
  echo "FAIL: a tag-only pod was not admitted in kube-system"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: the policy applies to shipyard only"
fi
exit "$fail"
