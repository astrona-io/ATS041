#!/usr/bin/env bash
# Runs only by `astrona test`: wait until the policy rejects a pod.
set -uo pipefail
for i in $(seq 1 30); do
  out="$(kubectl create --dry-run=server -f - 2>&1 <<MANIFEST || true
apiVersion: v1
kind: Pod
metadata:
  name: wait-probe
  namespace: shipyard
spec:
  serviceAccountName: loader
  containers:
  - name: main
    image: docker.io/library/busybox:1.37
MANIFEST
)"
  if echo "$out" | grep -q "denied request"; then
    echo "[testing] Policy is enforced."
    exit 0
  fi
  sleep 2
done
echo "[testing] Policy is not enforced yet." >&2
exit 1
