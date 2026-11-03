#!/usr/bin/env bash
# Check: state and behaviour. outpost enforces exactly baseline, no workload
# mounts a host path, and the API server rejects a host path pod and accepts a
# plain pod (server-side dry runs, nothing is created).
set -uo pipefail

fail=0

level="$(kubectl get namespace outpost -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$level" != "baseline" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on outpost is '${level}', expected 'baseline'"
  fail=1
fi

if kubectl -n outpost get deployment drifter-hostmount >/dev/null 2>&1; then
  echo "FAIL: Deployment drifter-hostmount still exists"
  fail=1
fi

pods="$(kubectl -n outpost get pods -o json 2>/dev/null | jq -r '
  .items[]
  | select(.metadata.deletionTimestamp == null)
  | select([.spec.volumes[]? | select(.hostPath != null)] | length > 0)
  | .metadata.name' 2>/dev/null)"
if [ -n "$pods" ]; then
  echo "FAIL: pods in outpost still mount a host path: $pods"
  fail=1
fi

hostpath_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-hostpath
  namespace: outpost
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
  echo "FAIL: the API server did not reject a host path pod in outpost with a PodSecurity error"
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
  echo "PASS: outpost enforces baseline and no workload mounts a host path"
fi
exit "$fail"
