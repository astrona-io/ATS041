#!/usr/bin/env bash
# Check: the shuttle pods do not receive an API token. The effective value is
# the pod setting if present, otherwise the service account setting. Also
# checks the running pods, so a template change that has not rolled out fails.
set -uo pipefail

pod_value="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.automountServiceAccountToken}' 2>/dev/null || true)"
sa_value="$(kubectl -n starfleet get serviceaccount shuttle -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null || true)"
effective="${pod_value:-$sa_value}"
if [ "$effective" != "false" ]; then
  echo "FAIL: automountServiceAccountToken is not false for shuttle (pod='${pod_value}', service account='${sa_value}')"
  exit 1
fi

if ! kubectl -n starfleet rollout status deployment/shuttle --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the shuttle Deployment did not finish rolling out"
  exit 1
fi

with_token="$(kubectl -n starfleet get pods -l app=shuttle -o json | jq -r '
  .items[]
  | select(.metadata.deletionTimestamp == null)
  | select(any(.spec.volumes[]?; (.name | startswith("kube-api-access"))))
  | .metadata.name')"
if [ -n "$with_token" ]; then
  echo "FAIL: running shuttle pods still have the token volume: $with_token"
  exit 1
fi

echo "PASS: shuttle pods have no API token volume"
