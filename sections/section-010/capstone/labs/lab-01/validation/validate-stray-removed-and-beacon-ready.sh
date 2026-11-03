#!/usr/bin/env bash
# Check: the unmanaged pod is gone and the hardened beacon is rolled out and
# ready. A beacon template that restricted rejects would never become ready.
set -uo pipefail

if kubectl -n relay get pod stray >/dev/null 2>&1; then
  echo "FAIL: the pod stray still exists in relay"
  exit 1
fi

if ! kubectl -n relay rollout status deployment/beacon --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the beacon Deployment did not finish rolling out"
  exit 1
fi

ready="$(kubectl -n relay get deployment beacon -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: beacon has no ready replica"
  exit 1
fi

echo "PASS: stray is removed and beacon is rolled out and ready"
