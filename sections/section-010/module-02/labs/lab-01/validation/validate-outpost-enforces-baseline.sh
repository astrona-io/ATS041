#!/usr/bin/env bash
# Check: outpost enforces at least the baseline Pod Security level. Rejects
# the privileged level and audit or warn only.
set -uo pipefail

level="$(kubectl get namespace outpost -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$level" != "baseline" ] && [ "$level" != "restricted" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on outpost is '${level}', expected 'baseline' or 'restricted'"
  exit 1
fi

echo "PASS: outpost enforces the ${level} level"
