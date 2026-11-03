#!/usr/bin/env bash
# Check: the beacon container has a memory request and limit, and the
# ResourceQuota orbit-quota caps pods at 5 and limits.memory at 512Mi.
set -uo pipefail

fail=0

if ! kubectl -n orbit get deployment beacon -o json 2>/dev/null | jq -e '.spec.template.spec.containers[] | select(.name=="beacon") | (.resources.requests.memory // "") != "" and (.resources.limits.memory // "") != ""' >/dev/null 2>&1; then
  echo "FAIL: the beacon container needs a memory request and a memory limit"
  fail=1
fi

quota="$(kubectl -n orbit get resourcequota orbit-quota -o json 2>/dev/null)" || quota=""
if [ -z "$quota" ]; then
  echo "FAIL: the ResourceQuota orbit-quota does not exist in orbit"
  exit 1
fi
if [ "$(echo "$quota" | jq -r '.spec.hard.pods // ""')" != "5" ]; then
  echo "FAIL: orbit-quota must set hard pods to 5"
  fail=1
fi
if [ "$(echo "$quota" | jq -r '.spec.hard["limits.memory"] // ""')" != "512Mi" ]; then
  echo "FAIL: orbit-quota must set hard limits.memory to 512Mi"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon has memory bounds and orbit-quota caps pods and memory limits"
fi
exit "$fail"
