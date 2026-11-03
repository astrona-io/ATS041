#!/usr/bin/env bash
# Check: every container of probe sets resources.limits.memory, and scout,
# probe and shuttle each have an available replica.
set -uo pipefail

fail=0

missing="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null \
  | jq -r '.spec.template.spec.containers[] | select((.resources.limits.memory // null) == null) | .name' || true)"
if [ -n "$missing" ] || ! kubectl -n starfleet get deployment probe >/dev/null 2>&1; then
  echo "FAIL: the probe Deployment is missing or a container has no memory limit: $missing"
  fail=1
fi

for name in scout probe shuttle; do
  available="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
  if [ -z "$available" ] || [ "$available" -lt 1 ]; then
    echo "FAIL: deployment $name in starfleet has no available replica"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has a memory limit and all workloads are available"
fi
exit "$fail"
