#!/usr/bin/env bash
# Check: ledger gets ledger-db through a secret volume named db-credentials,
# mounted read only at /etc/ledger-db in the ledger container.
set -uo pipefail

json="$(kubectl -n starfleet get deployment ledger -o json 2>/dev/null)" || {
  echo "FAIL: the ledger Deployment does not exist"
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

check "the pod needs a volume named db-credentials that uses the Secret ledger-db" \
  '[.spec.template.spec.volumes[]? | select(.name == "db-credentials" and .secret.secretName == "ledger-db")] | length == 1'
check "the ledger container must mount db-credentials at /etc/ledger-db" \
  '[.spec.template.spec.containers[] | select(.name == "ledger") | .volumeMounts[]? | select(.name == "db-credentials" and .mountPath == "/etc/ledger-db")] | length == 1'
check "the mount of db-credentials must be readOnly" \
  '[.spec.template.spec.containers[] | select(.name == "ledger") | .volumeMounts[]? | select(.name == "db-credentials" and .readOnly == true)] | length == 1'

if [ "$fail" -eq 0 ]; then
  echo "PASS: ledger mounts ledger-db read only at /etc/ledger-db"
fi
exit "$fail"
