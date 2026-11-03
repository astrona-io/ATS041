#!/usr/bin/env bash
# Check: behaviour. A server-side dry run of a Deployment without a memory
# limit is rejected by the policy in starfleet. Nothing is created. The check
# retries for up to 20 seconds because a changed binding needs a moment.
set -uo pipefail

for attempt in $(seq 1 20); do
  output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-nolimits
  namespace: starfleet
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grader-nolimits
  template:
    metadata:
      labels:
        app: grader-nolimits
    spec:
      containers:
        - name: trial
          image: ghcr.io/stefanprodan/podinfo:6.15.0
YAML
)"
  status=$?
  if [ "$status" -ne 0 ] && echo "$output" | grep -q 'require-memory-limits'; then
    echo "PASS: starfleet rejects a Deployment without a memory limit"
    exit 0
  fi
  sleep 1
done
echo "FAIL: a Deployment without a memory limit was not rejected by require-memory-limits in starfleet"
exit 1
