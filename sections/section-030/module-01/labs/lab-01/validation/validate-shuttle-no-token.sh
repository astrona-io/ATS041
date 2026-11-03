#!/usr/bin/env bash
# Check: the shuttle pod template sets automountServiceAccountToken to false
# and no running shuttle pod mounts the service account token directory.
set -uo pipefail

fail=0

setting="$(kubectl -n starfleet get deployment shuttle -o json 2>/dev/null | jq -r '.spec.template.spec.automountServiceAccountToken // "unset"')"
if [ "$setting" != "false" ]; then
  echo "FAIL: shuttle pod template has automountServiceAccountToken '$setting', expected false"
  fail=1
fi

mounting="$(kubectl -n starfleet get pods -l app=shuttle -o json 2>/dev/null \
  | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(any(.spec.containers[].volumeMounts[]?; .mountPath == "/var/run/secrets/kubernetes.io/serviceaccount")) | .metadata.name' || true)"
if [ -n "$mounting" ]; then
  echo "FAIL: these shuttle pods still mount the token: $mounting"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle pods do not mount a service account token"
fi
exit "$fail"
