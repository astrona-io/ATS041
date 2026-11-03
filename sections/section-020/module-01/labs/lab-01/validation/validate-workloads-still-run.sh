#!/usr/bin/env bash
# Check: state. scout, probe and shuttle keep every replica available, drifter
# still exists, and outpost has no NetworkPolicy (the task says to leave it).
set -uo pipefail

fail=0

for name in scout probe shuttle; do
  desired="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  available="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
  if [ -z "$desired" ] || [ "${desired:-0}" -lt 1 ]; then
    echo "FAIL: Deployment $name is missing or scaled to zero"
    fail=1
    continue
  fi
  if [ "${available:-0}" != "$desired" ]; then
    echo "FAIL: Deployment $name has ${available:-0} of $desired replicas available"
    fail=1
  fi
done

if ! kubectl -n outpost get deployment drifter >/dev/null 2>&1; then
  echo "FAIL: Deployment drifter in outpost is missing"
  fail=1
fi

count="$(kubectl -n outpost get networkpolicy -o json 2>/dev/null | jq '.items | length' 2>/dev/null || echo 0)"
if [ "${count:-0}" != "0" ]; then
  echo "FAIL: outpost has a NetworkPolicy, but the task says not to change it"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the workloads run and outpost is unchanged"
fi
exit "$fail"
