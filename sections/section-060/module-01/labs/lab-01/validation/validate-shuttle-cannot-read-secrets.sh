#!/usr/bin/env bash
# Check: the shuttle service account exists and may not get, list or watch
# Secrets in starfleet. The answer comes from the API server (can-i), so any
# way of removing the grant passes and deleting the service account does not.
set -uo pipefail

if ! kubectl -n starfleet get serviceaccount shuttle >/dev/null 2>&1; then
  echo "FAIL: the service account shuttle does not exist"
  exit 1
fi

fail=0
for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: shuttle can still '$verb' secrets in starfleet (can-i answered '${answer}')"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle may not read Secrets in starfleet"
fi
exit "$fail"
