#!/usr/bin/env bash
# Check: no hostPath volume in the pod template. Rejects a fix that only
# removes the volumeMount, or that swaps in another host-backed volume.
set -uo pipefail

spec="$(kubectl -n outpost get deployment relay -o json 2>/dev/null | jq '.spec.template.spec')" || spec=""
if [ -z "$spec" ] || [ "$spec" = "null" ]; then
  echo "FAIL: Deployment relay not found in outpost"
  exit 1
fi

fail=0
if [ "$(echo "$spec" | jq '[(.volumes // [])[] | select(.hostPath != null)] | length')" -ne 0 ]; then
  echo "FAIL: the relay pod template still has a hostPath volume"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[] | (.volumeMounts // [])[] | select(.name == "host-logs")] | length')" -ne 0 ]; then
  echo "FAIL: a relay container still mounts host-logs"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay has no hostPath volume"
fi
exit "$fail"
