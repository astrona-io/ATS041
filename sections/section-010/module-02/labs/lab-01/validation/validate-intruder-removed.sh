#!/usr/bin/env bash
# Check: the unmanaged privileged pod is gone and drifter still runs.
# Rejects deleting the whole namespace or the drifter Deployment.
set -uo pipefail

if kubectl -n outpost get pod intruder >/dev/null 2>&1; then
  echo "FAIL: the pod intruder still exists in outpost"
  exit 1
fi

ready="$(kubectl -n outpost get deployment drifter -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: drifter has no ready replica in outpost"
  exit 1
fi

echo "PASS: intruder is removed and drifter is running"
