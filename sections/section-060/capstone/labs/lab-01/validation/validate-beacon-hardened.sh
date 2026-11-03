#!/usr/bin/env bash
# Check: the beacon pod template has every container setting from the task.
set -uo pipefail

json="$(kubectl -n orbit get deployment beacon -o json 2>/dev/null)" || {
  echo "FAIL: the beacon Deployment does not exist"
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

check "beacon must run as non-root (runAsNonRoot true)" \
  '(.spec.template.spec.containers[] | select(.name=="beacon")) as $c
   | (($c.securityContext.runAsNonRoot // .spec.template.spec.securityContext.runAsNonRoot) == true)'
check "beacon must run as the user 65532" \
  '(.spec.template.spec.containers[] | select(.name=="beacon")) as $c
   | (($c.securityContext.runAsUser // .spec.template.spec.securityContext.runAsUser) == 65532)'
check "the seccomp profile must be RuntimeDefault" \
  '(.spec.template.spec.containers[] | select(.name=="beacon")) as $c
   | (($c.securityContext.seccompProfile.type // .spec.template.spec.securityContext.seccompProfile.type) == "RuntimeDefault")'
check "allowPrivilegeEscalation must be false on the beacon container" \
  '.spec.template.spec.containers[] | select(.name=="beacon") | .securityContext.allowPrivilegeEscalation == false'
check "readOnlyRootFilesystem must be true on the beacon container" \
  '.spec.template.spec.containers[] | select(.name=="beacon") | .securityContext.readOnlyRootFilesystem == true'
check "the beacon container must drop ALL capabilities" \
  '.spec.template.spec.containers[] | select(.name=="beacon") | ((.securityContext.capabilities.drop // []) | index("ALL")) != null'
check "the beacon container must not be privileged" \
  '.spec.template.spec.containers[] | select(.name=="beacon") | ((.securityContext.privileged // false) == false)'

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon has the container settings"
fi
exit "$fail"
