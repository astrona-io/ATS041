#!/usr/bin/env bash
# Check: behaviour. scout cannot get or list Secrets in starfleet and can still
# get the ConfigMap fleet-settings.
set -uo pipefail

identity="system:serviceaccount:starfleet:scout"
fail=0

for verb in get list; do
  answer="$(kubectl auth can-i "$verb" secrets -n starfleet --as="$identity" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: scout can still $verb Secrets in starfleet: answer '$answer'"
    fail=1
  fi
done

answer="$(kubectl auth can-i get configmaps/fleet-settings -n starfleet --as="$identity" 2>/dev/null || true)"
if [ "$answer" != "yes" ]; then
  echo "FAIL: scout cannot get the ConfigMap fleet-settings: answer '$answer'"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout reads fleet-settings and no Secret"
fi
exit "$fail"
