#!/usr/bin/env bash
# Check: behaviour. The API server rejects a privileged pod in outpost and
# admits a plain pod. Both are server-side dry runs, so nothing is created.
set -uo pipefail

fail=0

privileged_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-privileged
  namespace: outpost
spec:
  containers:
    - name: test
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      securityContext:
        privileged: true
YAML
)"
privileged_status=$?
if [ "$privileged_status" -eq 0 ] || ! echo "$privileged_output" | grep -q 'PodSecurity'; then
  echo "FAIL: the API server did not reject a privileged pod in outpost with a PodSecurity error"
  fail=1
fi

plain_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-plain
  namespace: outpost
spec:
  containers:
    - name: test
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
YAML
)"
plain_status=$?
if [ "$plain_status" -ne 0 ]; then
  echo "FAIL: the API server rejected a plain pod in outpost: $plain_output"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the privileged pod is rejected and a plain pod is accepted"
fi
exit "$fail"
