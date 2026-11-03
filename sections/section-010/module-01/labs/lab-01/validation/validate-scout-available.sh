#!/usr/bin/env bash
# Check: scout still serves. The hardened template must have rolled out and a
# pod must be ready, so a securityContext that breaks the image fails here.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the scout Deployment did not finish rolling out"
  exit 1
fi

ready="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: scout has no ready replica"
  exit 1
fi

echo "PASS: scout is rolled out and ready"
