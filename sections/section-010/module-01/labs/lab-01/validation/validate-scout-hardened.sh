#!/usr/bin/env bash
# Check: the scout container is not privileged, cannot gain privileges, drops
# all capabilities, runs as non-root and mounts no host path. Rejects partial fixes.
set -uo pipefail

json="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null)" || {
  echo "FAIL: the scout Deployment does not exist"
  exit 1
}

fail=0
check() {
  local description="$1" filter="$2"
  if ! echo "$json" | jq -e "$filter" >/dev/null 2>&1; then
    echo "FAIL: $description"
    fail=1
  fi
}

check "the scout container must not be privileged" \
  '.spec.template.spec.containers[] | select(.name=="scout") | ((.securityContext.privileged // false) == false)'
check "allowPrivilegeEscalation must be false on the scout container" \
  '.spec.template.spec.containers[] | select(.name=="scout") | .securityContext.allowPrivilegeEscalation == false'
check "the scout container must drop ALL capabilities" \
  '.spec.template.spec.containers[] | select(.name=="scout") | ((.securityContext.capabilities.drop // []) | index("ALL")) != null'
check "scout must run as non-root with a non-zero user (runAsNonRoot true, runAsUser not 0)" \
  '(.spec.template.spec.containers[] | select(.name=="scout")) as $c
   | ((($c.securityContext.runAsNonRoot // .spec.template.spec.securityContext.runAsNonRoot) == true)
      and ((($c.securityContext.runAsUser // .spec.template.spec.securityContext.runAsUser) // 1) != 0))'
check "scout must not mount a hostPath volume" \
  '[.spec.template.spec.volumes[]? | select(.hostPath != null)] | length == 0'

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout is hardened and mounts no host path"
fi
exit "$fail"
