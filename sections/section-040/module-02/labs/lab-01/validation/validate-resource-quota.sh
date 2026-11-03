#!/usr/bin/env bash
# Check: depot has a ResourceQuota that caps pods (at most 10) and the memory
# and CPU requests and memory limits.
set -uo pipefail

quotas="$(kubectl -n depot get resourcequota -o json 2>/dev/null)" || quotas=""
if [ -z "$quotas" ]; then
  echo "FAIL: could not read ResourceQuotas in depot"
  exit 1
fi

ok="$(echo "$quotas" | jq '[.items[]
  | select((.spec.hard.pods != null) and ((.spec.hard.pods | tonumber) <= 10))
  | select(.spec.hard["requests.cpu"] != null)
  | select(.spec.hard["requests.memory"] != null)
  | select(.spec.hard["limits.memory"] != null)] | length')"

if [ "$ok" -lt 1 ]; then
  echo "FAIL: no ResourceQuota in depot sets pods (at most 10), requests.cpu, requests.memory and limits.memory"
  exit 1
fi
echo "PASS: depot has a ResourceQuota on pods, requests and limits"
