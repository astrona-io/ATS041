#!/usr/bin/env bash
# Check: Secret ledger-db exists in starfleet and its key password decodes to
# the original value. Rejects a Secret with another key name or another value.
set -uo pipefail

encoded="$(kubectl -n starfleet get secret ledger-db -o jsonpath='{.data.password}' 2>/dev/null || true)"
if [ -z "$encoded" ]; then
  echo "FAIL: Secret ledger-db with a key 'password' does not exist in starfleet"
  exit 1
fi

value="$(printf '%s' "$encoded" | base64 -d 2>/dev/null || true)"
if [ "$value" != "ledger-pass-7" ]; then
  echo "FAIL: the key 'password' in ledger-db does not hold the original password"
  exit 1
fi

echo "PASS: ledger-db holds the original password in the key 'password'"
