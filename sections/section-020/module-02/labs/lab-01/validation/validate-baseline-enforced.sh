#!/usr/bin/env bash
# Check: state and behaviour. starfleet enforces exactly baseline. The API
# server rejects a hostPath pod and accepts a plain pod. Both are server-side
# dry runs, so nothing is created.
set -uo pipefail

fail=0

level="$(kubectl get namespace starfleet -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$level" != "baseline" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on starfleet is '${level}', expected 'baseline'"
  fail=1
fi

hostpath_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-hostpath
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      volumeMounts:
        - name: node-etc
          mountPath: /node-etc
  volumes:
    - name: node-etc
      hostPath:
        path: /etc/kubernetes
YAML
)"
hostpath_status=$?
if [ "$hostpath_status" -eq 0 ] || ! echo "$hostpath_output" | grep -q 'violates PodSecurity'; then
  echo "FAIL: the API server did not reject a host path pod in starfleet with a PodSecurity error"
  fail=1
fi

plain_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-plain
  namespace: starfleet
spec:
  containers:
    - name: probe
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
YAML
)"
plain_status=$?
if [ "$plain_status" -ne 0 ]; then
  echo "FAIL: the API server rejected a plain pod: $plain_output"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: baseline is enforced, the host path pod is rejected and the plain pod is accepted"
fi
exit "$fail"
