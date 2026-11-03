#!/usr/bin/env bash
# Check: digest-pinned pods are admitted in shipyard; tag-only pods, tag-only init containers and malformed digests are rejected.
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
good_digest="sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

if ! expect_admitted shipyard loader "ghcr.io/stefanprodan/podinfo@${good_digest}"; then
  echo "FAIL: a pod that uses a digest was not admitted in shipyard"
  fail=1
fi
if ! expect_admitted shipyard loader "ghcr.io/stefanprodan/podinfo@${good_digest}" "registry.starfleet.example/fleet/tug@${good_digest}"; then
  echo "FAIL: a pod with digests in every container and init container was not admitted"
  fail=1
fi
if ! expect_denied shipyard loader ghcr.io/stefanprodan/podinfo:6.15.0; then
  echo "FAIL: a pod that uses only a tag was not rejected in shipyard"
  fail=1
fi
if ! expect_denied shipyard loader "ghcr.io/stefanprodan/podinfo@${good_digest}" registry.starfleet.example/fleet/tug:1.9; then
  echo "FAIL: a pod with a tag-only init container was not rejected"
  fail=1
fi
if ! expect_denied shipyard loader "ghcr.io/stefanprodan/podinfo:6.15.0@sha256:abc" ; then
  echo "FAIL: a pod with a malformed digest was not rejected"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: only digest-pinned images are admitted in shipyard"
fi
exit "$fail"
