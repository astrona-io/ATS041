#!/usr/bin/env bash
# Check: behaviour. build-runner can still do its job in starfleet and nothing
# more: it may get, list, patch and update Deployments there, and may not
# create or delete them there or patch them in outpost.
set -uo pipefail

identity="system:serviceaccount:starfleet:build-runner"
fail=0

for verb in get list patch update; do
  answer="$(kubectl auth can-i "$verb" deployments.apps -n starfleet --as="$identity" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: build-runner cannot $verb Deployments in starfleet: answer '$answer'"
    fail=1
  fi
done

for verb in create delete; do
  answer="$(kubectl auth can-i "$verb" deployments.apps -n starfleet --as="$identity" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: build-runner can $verb Deployments in starfleet, which is more than it needs: answer '$answer'"
    fail=1
  fi
done

answer="$(kubectl auth can-i patch deployments.apps -n outpost --as="$identity" 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: build-runner can patch Deployments in outpost: answer '$answer'"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: build-runner updates Deployments in starfleet and nothing more"
fi
exit "$fail"
