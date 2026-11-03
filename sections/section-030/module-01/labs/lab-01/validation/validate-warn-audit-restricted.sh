#!/usr/bin/env bash
# Check: warn and audit on starfleet are both restricted.
set -uo pipefail

fail=0
for mode in warn audit; do
  level="$(kubectl get namespace starfleet -o json | jq -r --arg key "pod-security.kubernetes.io/$mode" '.metadata.labels[$key] // "none"')"
  if [ "$level" != "restricted" ]; then
    echo "FAIL: pod-security.kubernetes.io/$mode on starfleet is '$level', expected 'restricted'"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: starfleet warns and audits at restricted"
fi
exit "$fail"
