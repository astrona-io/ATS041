#!/usr/bin/env bash
# Check: the relay pod template shares no host namespace.
set -uo pipefail

spec="$(kubectl -n outpost get deployment relay -o json 2>/dev/null | jq '.spec.template.spec')" || spec=""
if [ -z "$spec" ] || [ "$spec" = "null" ]; then
  echo "FAIL: Deployment relay not found in outpost"
  exit 1
fi

fail=0
for field in hostPID hostNetwork hostIPC; do
  value="$(echo "$spec" | jq -r --arg f "$field" '.[$f] // false')"
  if [ "$value" != "false" ]; then
    echo "FAIL: the relay pod template sets $field to $value"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay shares no host PID, network or IPC namespace"
fi
exit "$fail"
