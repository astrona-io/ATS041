#!/usr/bin/env bash
# Check: beacon pods receive no API token. The effective value is the pod
# setting if present, otherwise the service account setting. Running pods are
# checked too.
set -uo pipefail

pod_value="$(kubectl -n relay get deployment beacon -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null || true)"
sa_value="$(kubectl -n relay get serviceaccount beacon -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null || true)"
effective="${pod_value:-$sa_value}"
if [ "$effective" != "false" ]; then
  echo "FAIL: automountServiceAccountToken is not false for beacon (pod='${pod_value}', service account='${sa_value}')"
  exit 1
fi

with_token="$(kubectl -n relay get pods -l app=beacon -o json | jq -r '
  .items[]
  | select(.metadata.deletionTimestamp == null)
  | select(any(.spec.volumes[]?; (.name | startswith("kube-api-access"))))
  | .metadata.name')"
if [ -n "$with_token" ]; then
  echo "FAIL: running beacon pods still have the token volume: $with_token"
  exit 1
fi

echo "PASS: beacon pods have no API token volume"
