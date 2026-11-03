#!/usr/bin/env bash
# Check: every container is unprivileged, cannot escalate and drops ALL
# capabilities. Rejects a fix that drops ALL and then adds capabilities back.
set -uo pipefail

spec="$(kubectl -n outpost get deployment relay -o json 2>/dev/null | jq '.spec.template.spec')" || spec=""
if [ -z "$spec" ] || [ "$spec" = "null" ]; then
  echo "FAIL: Deployment relay not found in outpost"
  exit 1
fi

fail=0
count="$(echo "$spec" | jq '[.containers[], (.initContainers // [])[]] | length')"
if [ "$count" -lt 1 ]; then
  echo "FAIL: the relay pod template has no containers"
  exit 1
fi

if [ "$(echo "$spec" | jq '[.containers[], (.initContainers // [])[] | select(.securityContext.privileged == true)] | length')" -ne 0 ]; then
  echo "FAIL: a relay container is still privileged"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[], (.initContainers // [])[] | select(.securityContext.allowPrivilegeEscalation != false)] | length')" -ne 0 ]; then
  echo "FAIL: a relay container does not set allowPrivilegeEscalation to false"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[], (.initContainers // [])[] | select(((.securityContext.capabilities.drop // []) | index("ALL")) == null)] | length')" -ne 0 ]; then
  echo "FAIL: a relay container does not drop ALL capabilities"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[], (.initContainers // [])[] | select(((.securityContext.capabilities.add // []) | length) > 0)] | length')" -ne 0 ]; then
  echo "FAIL: a relay container adds capabilities back"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay containers are unprivileged, cannot escalate and drop ALL capabilities"
fi
exit "$fail"
