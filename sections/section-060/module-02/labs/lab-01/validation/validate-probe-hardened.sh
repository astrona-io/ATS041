#!/usr/bin/env bash
# Check: the probe pod template has every container setting from the task.
# Looks at pod level and container level, because the container value wins.
set -uo pipefail

json="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null)" || {
  echo "FAIL: the probe Deployment does not exist"
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

check "probe must run as non-root (runAsNonRoot true)" \
  '(.spec.template.spec.containers[] | select(.name=="probe")) as $c
   | (($c.securityContext.runAsNonRoot // .spec.template.spec.securityContext.runAsNonRoot) == true)'
check "probe must run as the user 65532" \
  '(.spec.template.spec.containers[] | select(.name=="probe")) as $c
   | (($c.securityContext.runAsUser // .spec.template.spec.securityContext.runAsUser) == 65532)'
check "the seccomp profile must be RuntimeDefault" \
  '(.spec.template.spec.containers[] | select(.name=="probe")) as $c
   | (($c.securityContext.seccompProfile.type // .spec.template.spec.securityContext.seccompProfile.type) == "RuntimeDefault")'
check "allowPrivilegeEscalation must be false on the probe container" \
  '.spec.template.spec.containers[] | select(.name=="probe") | .securityContext.allowPrivilegeEscalation == false'
check "readOnlyRootFilesystem must be true on the probe container" \
  '.spec.template.spec.containers[] | select(.name=="probe") | .securityContext.readOnlyRootFilesystem == true'
check "the probe container must drop ALL capabilities and add none" \
  '.spec.template.spec.containers[] | select(.name=="probe") | ((.securityContext.capabilities.drop // []) | index("ALL")) != null and ((.securityContext.capabilities.add // []) | length == 0)'
check "the probe container must not be privileged" \
  '.spec.template.spec.containers[] | select(.name=="probe") | ((.securityContext.privileged // false) == false)'

if [ "$fail" -eq 0 ]; then
  echo "PASS: the probe pod template has the container settings"
fi
exit "$fail"
