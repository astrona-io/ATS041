#!/usr/bin/env bash
# Check: the courier pod template has no host access. Rejects a fix that
# leaves hostNetwork, hostPID, a hostPath volume or the token in place, and a
# fix that drops ALL capabilities and adds some back.
set -uo pipefail

spec="$(kubectl -n annex get deployment courier -o json 2>/dev/null | jq '.spec.template.spec')" || spec=""
if [ -z "$spec" ] || [ "$spec" = "null" ]; then
  echo "FAIL: Deployment courier not found in annex"
  exit 1
fi

fail=0
for field in hostPID hostNetwork hostIPC; do
  if [ "$(echo "$spec" | jq -r --arg f "$field" '.[$f] // false')" != "false" ]; then
    echo "FAIL: the courier pod template sets $field to true"
    fail=1
  fi
done
if [ "$(echo "$spec" | jq '[.containers[] | select(.securityContext.privileged == true)] | length')" -ne 0 ]; then
  echo "FAIL: the courier container is still privileged"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[] | select(.securityContext.allowPrivilegeEscalation != false)] | length')" -ne 0 ]; then
  echo "FAIL: the courier container does not set allowPrivilegeEscalation to false"
  fail=1
fi
if [ "$(echo "$spec" | jq '[.containers[] | select(((.securityContext.capabilities.drop // []) | index("ALL")) == null or ((.securityContext.capabilities.add // []) | length) > 0)] | length')" -ne 0 ]; then
  echo "FAIL: the courier container must drop ALL capabilities and add none"
  fail=1
fi
if [ "$(echo "$spec" | jq '[(.volumes // [])[] | select(.hostPath != null)] | length')" -ne 0 ]; then
  echo "FAIL: the courier pod template still has a hostPath volume"
  fail=1
fi
sa_value="$(kubectl -n annex get serviceaccount courier -o json 2>/dev/null | jq -r '.automountServiceAccountToken // "unset"')"
pod_value="$(echo "$spec" | jq -r '.automountServiceAccountToken // "unset"')"
if [ "$pod_value" != "false" ] && { [ "$pod_value" != "unset" ] || [ "$sa_value" != "false" ]; }; then
  echo "FAIL: courier pods still receive a service account token"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the courier pod template has no host access and no token"
fi
exit "$fail"
