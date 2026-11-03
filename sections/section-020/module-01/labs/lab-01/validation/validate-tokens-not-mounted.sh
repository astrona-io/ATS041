#!/usr/bin/env bash
# Check: state and behaviour. The pod templates of scout and probe switch the
# token mount off, and no running pod of either Deployment still has the
# projected service account token volume. Reading the pods catches a template
# change whose rollout has not finished.
set -uo pipefail

fail=0

for name in scout probe; do
  setting="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null || true)"
  if [ "$setting" != "false" ]; then
    echo "FAIL: the pod template of $name does not set automountServiceAccountToken to false"
    fail=1
  fi

  with_token="$(kubectl -n starfleet get pods -l "app=$name" -o json 2>/dev/null | jq -r '
    .items[]
    | select(.metadata.deletionTimestamp == null)
    | select([.spec.volumes[]? | .projected.sources[]? | select(.serviceAccountToken != null)] | length > 0)
    | .metadata.name' 2>/dev/null)"
  if [ -n "$with_token" ]; then
    echo "FAIL: running pods of $name still have a service account token volume: $with_token"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout and probe run without a service account token"
fi
exit "$fail"
