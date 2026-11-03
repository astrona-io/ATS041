#!/usr/bin/env bash
# Check: behaviour and state. The API server rejects a privileged pod in
# starfleet (server-side dry run, nothing is created) and no privileged
# container runs there any more.
set -uo pipefail

fail=0

output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-privileged
  namespace: starfleet
spec:
  containers:
    - name: trial
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      securityContext:
        privileged: true
YAML
)"
status=$?
if [ "$status" -eq 0 ] || ! echo "$output" | grep -q 'violates PodSecurity'; then
  echo "FAIL: the API server did not reject a privileged pod in starfleet with a PodSecurity error"
  fail=1
fi

if kubectl -n starfleet get deployment debug-tools >/dev/null 2>&1; then
  echo "FAIL: the debug-tools Deployment still exists"
  fail=1
fi

# A pod that is already shutting down (deletionTimestamp set) does not count.
privileged="$(kubectl -n starfleet get pods -o json 2>/dev/null \
  | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(any(.spec.containers[]; .securityContext.privileged == true)) | .metadata.name' || true)"
if [ -n "$privileged" ]; then
  echo "FAIL: privileged pods still run in starfleet: $privileged"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: privileged pods are rejected and none run"
fi
exit "$fail"
