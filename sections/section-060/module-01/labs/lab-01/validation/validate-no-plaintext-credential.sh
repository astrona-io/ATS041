#!/usr/bin/env bash
# Check: the ledger pod template has no literal password. It looks at the whole
# template, so the value cannot hide in an argument, a command or another variable.
set -uo pipefail

template="$(kubectl -n starfleet get deployment ledger -o json 2>/dev/null | jq -c '.spec.template')" || template=""
if [ -z "$template" ] || [ "$template" = "null" ]; then
  echo "FAIL: the ledger Deployment does not exist"
  exit 1
fi

fail=0
if echo "$template" | jq -e 'tostring | contains("ledger-pass-7")' >/dev/null 2>&1; then
  echo "FAIL: the original password is still written in the ledger pod template"
  fail=1
fi
if echo "$template" | jq -e '[.spec.containers[].env[]? | select(.name == "DB_PASSWORD")] | length > 0' >/dev/null 2>&1; then
  echo "FAIL: the DB_PASSWORD variable is still in the ledger pod template"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the ledger pod template has no literal password"
fi
exit "$fail"
