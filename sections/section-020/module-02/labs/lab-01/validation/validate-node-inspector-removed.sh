#!/usr/bin/env bash
# Check: state. node-inspector is gone, and no Deployment or pod in starfleet
# mounts a hostPath volume.
set -uo pipefail

fail=0

if kubectl -n starfleet get deployment node-inspector >/dev/null 2>&1; then
  echo "FAIL: Deployment node-inspector still exists"
  fail=1
fi

pods="$(kubectl -n starfleet get pods -o json 2>/dev/null | jq -r '
  .items[]
  | select(.metadata.deletionTimestamp == null)
  | select([.spec.volumes[]? | select(.hostPath != null)] | length > 0)
  | .metadata.name' 2>/dev/null)"
if [ -n "$pods" ]; then
  echo "FAIL: pods in starfleet still mount a host path: $pods"
  fail=1
fi

deployments="$(kubectl -n starfleet get deployments -o json 2>/dev/null | jq -r '
  .items[]
  | select([.spec.template.spec.volumes[]? | select(.hostPath != null)] | length > 0)
  | .metadata.name' 2>/dev/null)"
if [ -n "$deployments" ]; then
  echo "FAIL: Deployments in starfleet still mount a host path: $deployments"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: no workload in starfleet mounts a host path"
fi
exit "$fail"
