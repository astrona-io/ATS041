#!/usr/bin/env bash
# Check: a server-side dry run of a privileged pod is rejected in orbit, the
# beacon-debug Deployment is gone and no privileged pod runs in orbit.
set -uo pipefail

fail=0

output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-privileged
  namespace: orbit
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
  echo "FAIL: the API server did not reject a privileged pod in orbit with a PodSecurity error"
  fail=1
fi

if kubectl -n orbit get deployment beacon-debug >/dev/null 2>&1; then
  echo "FAIL: the beacon-debug Deployment still exists"
  fail=1
fi

privileged="$(kubectl -n orbit get pods -o json 2>/dev/null \
  | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(any(.spec.containers[]; .securityContext.privileged == true)) | .metadata.name' || true)"
if [ -n "$privileged" ]; then
  echo "FAIL: privileged pods still run in orbit: $privileged"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: orbit rejects privileged pods and none run"
fi
exit "$fail"
