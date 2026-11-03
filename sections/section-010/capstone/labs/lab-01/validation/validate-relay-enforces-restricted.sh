#!/usr/bin/env bash
# Check: the enforce label is restricted and the API server behaves
# accordingly. Both pod tests are server-side dry runs.
set -uo pipefail

fail=0
level="$(kubectl get namespace relay -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$level" != "restricted" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on relay is '${level}', expected 'restricted'"
  fail=1
fi

privileged_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-privileged
  namespace: relay
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
  echo "FAIL: a privileged pod was not rejected with a PodSecurity error in relay"
  fail=1
fi

compliant_output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: grader-compliant
  namespace: relay
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: test
      image: curlimages/curl:8.22.0
      command: ["sleep", "30"]
      securityContext:
        allowPrivilegeEscalation: false
        capabilities:
          drop: ["ALL"]
YAML
)"
compliant_status=$?
if [ "$compliant_status" -ne 0 ]; then
  echo "FAIL: a pod that meets restricted was rejected: $compliant_output"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay enforces restricted"
fi
exit "$fail"
