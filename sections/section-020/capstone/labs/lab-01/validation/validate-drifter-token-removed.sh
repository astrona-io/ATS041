#!/usr/bin/env bash
# Check: state and behaviour. The drifter pod template switches the token mount
# off, no running drifter pod still has the projected token volume, and the
# Deployment is available.
set -uo pipefail

fail=0

setting="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null || true)"
if [ "$setting" != "false" ]; then
  echo "FAIL: the pod template of drifter does not set automountServiceAccountToken to false"
  fail=1
fi

with_token="$(kubectl -n outpost get pods -l app=drifter -o json 2>/dev/null | jq -r '
  .items[]
  | select(.metadata.deletionTimestamp == null)
  | select([.spec.volumes[]? | .projected.sources[]? | select(.serviceAccountToken != null)] | length > 0)
  | .metadata.name' 2>/dev/null)"
if [ -n "$with_token" ]; then
  echo "FAIL: running drifter pods still have a service account token volume: $with_token"
  fail=1
fi

desired="$(kubectl -n outpost get deployment drifter -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
available="$(kubectl -n outpost get deployment drifter -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ -z "$desired" ] || [ "${desired:-0}" -lt 1 ] || [ "${available:-0}" != "$desired" ]; then
  echo "FAIL: Deployment drifter is missing, scaled to zero or not fully available"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter runs without a service account token"
fi
exit "$fail"
