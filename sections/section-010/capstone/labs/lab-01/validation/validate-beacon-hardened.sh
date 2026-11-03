#!/usr/bin/env bash
# Check: the beacon template meets the restricted settings and mounts no host
# path. Rejects partial fixes.
set -uo pipefail

json="$(kubectl -n relay get deployment beacon -o json 2>/dev/null)" || {
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

C='.spec.template.spec.containers[] | select(.name=="beacon")'
check "the beacon container must not be privileged" "$C | ((.securityContext.privileged // false) == false)"
check "allowPrivilegeEscalation must be false" "$C | .securityContext.allowPrivilegeEscalation == false"
check "the container must drop ALL capabilities" "$C | ((.securityContext.capabilities.drop // []) | index(\"ALL\")) != null"
check "beacon must run as non-root with a non-zero user" \
  "($C) as \$c | ((((\$c.securityContext.runAsNonRoot // .spec.template.spec.securityContext.runAsNonRoot) == true)) and ((((\$c.securityContext.runAsUser // .spec.template.spec.securityContext.runAsUser) // 1) != 0)))"
check "the seccomp profile must be RuntimeDefault" \
  "($C) as \$c | ((\$c.securityContext.seccompProfile.type // .spec.template.spec.securityContext.seccompProfile.type) == \"RuntimeDefault\")"
check "beacon must not mount a hostPath volume" '[.spec.template.spec.volumes[]? | select(.hostPath != null)] | length == 0'

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon meets the restricted settings and mounts no host path"
fi
exit "$fail"
