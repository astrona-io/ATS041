#!/usr/bin/env bash
# Check: orbit enforces baseline and warns and audits at restricted.
set -uo pipefail

fail=0
check_label() {
  local mode="$1"
  local expected="$2"
  local level
  level="$(kubectl get namespace orbit -o json | jq -r --arg key "pod-security.kubernetes.io/$mode" '.metadata.labels[$key] // "none"')"
  if [ "$level" != "$expected" ]; then
    echo "FAIL: pod-security.kubernetes.io/$mode on orbit is '$level', expected '$expected'"
    fail=1
  fi
}

check_label enforce baseline
check_label warn restricted
check_label audit restricted

if [ "$fail" -eq 0 ]; then
  echo "PASS: orbit has the expected Pod Security labels"
fi
exit "$fail"
