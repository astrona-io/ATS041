#!/usr/bin/env bash
# Check: behaviour. In starfleet a Deployment with only resources.limits.memory
# is accepted and a Deployment with only resources.requests.memory is rejected
# by the policy. Both are server-side dry runs. Retries for up to 20 seconds.
set -uo pipefail

limits_only() {
  kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-limits
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grader-limits
  template:
    metadata:
      labels:
        app: grader-limits
    spec:
      containers:
        - name: trial
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          resources:
            limits:
              memory: 64Mi
YAML
}

requests_only() {
  kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-requests
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grader-requests
  template:
    metadata:
      labels:
        app: grader-requests
    spec:
      containers:
        - name: trial
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          resources:
            requests:
              memory: 32Mi
YAML
}

for attempt in $(seq 1 20); do
  limits_output="$(limits_only)"
  limits_status=$?
  requests_output="$(requests_only)"
  requests_status=$?
  if [ "$limits_status" -eq 0 ] && [ "$requests_status" -ne 0 ] && echo "$requests_output" | grep -q 'require-memory-limits'; then
    echo "PASS: the policy accepts a limit and rejects a request without a limit"
    exit 0
  fi
  sleep 1
done

if [ "$limits_status" -ne 0 ]; then
  echo "FAIL: a Deployment with resources.limits.memory was rejected: $limits_output"
fi
if [ "$requests_status" -eq 0 ]; then
  echo "FAIL: a Deployment with only resources.requests.memory was accepted"
fi
exit 1
