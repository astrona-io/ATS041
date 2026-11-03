#!/usr/bin/env bash
# Check: the ResourceQuota starfleet-quota caps pods at 10 and limits.memory at 1Gi.
set -uo pipefail

json="$(kubectl -n starfleet get resourcequota starfleet-quota -o json 2>/dev/null)" || {
  echo "FAIL: the ResourceQuota starfleet-quota does not exist in starfleet"
  exit 1
}

fail=0
if [ "$(echo "$json" | jq -r '.spec.hard.pods // ""')" != "10" ]; then
  echo "FAIL: starfleet-quota must set hard pods to 10"
  fail=1
fi
if [ "$(echo "$json" | jq -r '.spec.hard["limits.memory"] // ""')" != "1Gi" ]; then
  echo "FAIL: starfleet-quota must set hard limits.memory to 1Gi"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: starfleet-quota caps pods at 10 and limits.memory at 1Gi"
fi
exit "$fail"
