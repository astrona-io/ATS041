#!/usr/bin/env bash
# Check: the control is scoped to starfleet. A server-side dry run of a
# Deployment without a memory limit is still accepted in outpost, and outpost
# carries no control-scope label.
set -uo pipefail

fail=0

output="$(kubectl apply --dry-run=server -f - 2>&1 <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grader-nolimits
  namespace: outpost
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
if [ "$status" -ne 0 ]; then
  echo "FAIL: a Deployment without a memory limit was rejected in outpost: $output"
  fail=1
fi

scope="$(kubectl get namespace outpost -o json | jq -r '.metadata.labels["control-scope"] // "none"')"
if [ "$scope" != "none" ]; then
  echo "FAIL: outpost has the label control-scope=$scope"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost is outside the scope of the control"
fi
exit "$fail"
