#!/usr/bin/env bash
# Check: behaviour. With a binding in place, a server-side dry run of a
# Deployment without a memory limit is rejected by require-memory-limits in
# orbit and still accepted in starfleet and outpost. Retries for up to 20
# seconds because a new binding needs a moment.
set -uo pipefail

try_nolimits() {
  kubectl apply --dry-run=server -f - 2>&1 <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-nolimits
  namespace: $1
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
}

rejected_in_orbit=1
for attempt in $(seq 1 20); do
  output="$(try_nolimits orbit)"
  status=$?
  if [ "$status" -ne 0 ] && echo "$output" | grep -q 'require-memory-limits'; then
    rejected_in_orbit=0
    break
  fi
  sleep 1
done

fail=0
if [ "$rejected_in_orbit" -ne 0 ]; then
  echo "FAIL: a Deployment without a memory limit was not rejected by require-memory-limits in orbit"
  fail=1
fi

for namespace in starfleet outpost; do
  output="$(try_nolimits "$namespace")"
  status=$?
  if [ "$status" -ne 0 ]; then
    echo "FAIL: a Deployment without a memory limit was rejected in $namespace: $output"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: the policy denies in orbit and stays out of starfleet and outpost"
fi
exit "$fail"
