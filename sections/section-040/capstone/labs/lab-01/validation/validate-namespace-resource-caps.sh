#!/usr/bin/env bash
# Check: annex has a ResourceQuota (pods at most 6, requests.memory,
# limits.memory) and a Container LimitRange with memory defaults.
set -uo pipefail

fail=0
quotas="$(kubectl -n annex get resourcequota -o json 2>/dev/null)" || quotas='{"items":[]}'
ok="$(echo "$quotas" | jq '[.items[]
  | select((.spec.hard.pods != null) and ((.spec.hard.pods | tonumber) <= 6))
  | select(.spec.hard["requests.memory"] != null)
  | select(.spec.hard["limits.memory"] != null)] | length')"
if [ "$ok" -lt 1 ]; then
  echo "FAIL: no ResourceQuota in annex sets pods (at most 6), requests.memory and limits.memory"
  fail=1
fi

ranges="$(kubectl -n annex get limitrange -o json 2>/dev/null)" || ranges='{"items":[]}'
ok="$(echo "$ranges" | jq '[.items[].spec.limits[]
  | select(.type == "Container")
  | select(.default.memory != null)
  | select(.defaultRequest.memory != null)] | length')"
if [ "$ok" -lt 1 ]; then
  echo "FAIL: no Container LimitRange in annex sets default.memory and defaultRequest.memory"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: annex has a ResourceQuota and a LimitRange with memory defaults"
fi
exit "$fail"
