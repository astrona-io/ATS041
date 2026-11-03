#!/usr/bin/env bash
# Check: state. The fix must not break anything it was not asked to touch:
# every replica of scout, probe and shuttle is available, the Secret
# drive-credentials exists, and outpost has no Pod Security enforce label.
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

if ! kubectl -n starfleet get secret drive-credentials >/dev/null 2>&1; then
  echo "FAIL: the Secret drive-credentials was deleted"
  fail=1
fi

outpost_level="$(kubectl get namespace outpost -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ -n "$outpost_level" ]; then
  echo "FAIL: outpost has an enforce label ('$outpost_level'), but the task says not to change it"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the workloads run, the Secret exists and outpost is unchanged"
fi
exit "$fail"
