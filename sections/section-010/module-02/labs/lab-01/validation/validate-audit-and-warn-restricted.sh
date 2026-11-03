#!/usr/bin/env bash
# Check: outpost reports restricted violations in audit and warn modes.
set -uo pipefail

fail=0
for mode in audit warn; do
  level="$(kubectl get namespace outpost -o jsonpath="{.metadata.labels.pod-security\.kubernetes\.io/${mode}}" 2>/dev/null || true)"
  if [ "$level" != "restricted" ]; then
    echo "FAIL: pod-security.kubernetes.io/${mode} on outpost is '${level}', expected 'restricted'"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost audits and warns at the restricted level"
fi
exit "$fail"
