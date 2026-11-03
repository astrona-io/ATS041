#!/usr/bin/env bash
# Check: behaviour, with server-side dry runs, so nothing is created. A pod with
# no resources must be admitted (the LimitRange supplies the limit that the
# quota needs). A pod that asks for a 2Gi memory limit must be rejected with
# an "exceeded quota" error.
set -uo pipefail

fail=0

plain_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-plain
  namespace: starfleet
spec:
  serviceAccountName: scout
  automountServiceAccountToken: false
  containers:
    - name: client
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
YAML
)"
plain_status=$?
if [ "$plain_status" -ne 0 ]; then
  echo "FAIL: the API server rejected a pod with no resources: $plain_output"
  fail=1
fi

big_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-big
  namespace: starfleet
spec:
  serviceAccountName: scout
  automountServiceAccountToken: false
  containers:
    - name: client
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      resources:
        requests:
          memory: 2Gi
        limits:
          memory: 2Gi
YAML
)"
big_status=$?
if [ "$big_status" -eq 0 ] || ! echo "$big_output" | grep -q 'exceeded quota'; then
  echo "FAIL: the API server did not reject a pod with a 2Gi memory limit with an 'exceeded quota' error"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: a pod without resources is admitted and a pod over the quota is rejected"
fi
exit "$fail"
