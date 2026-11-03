#!/usr/bin/env bash
# Check: the enforce label on starfleet is exactly baseline.
set -uo pipefail

level="$(kubectl get namespace starfleet -o json | jq -r '.metadata.labels["pod-security.kubernetes.io/enforce"] // "none"')"

if [ "$level" != "baseline" ]; then
  echo "FAIL: pod-security.kubernetes.io/enforce on starfleet is '$level', expected 'baseline'"
  exit 1
fi
echo "PASS: starfleet enforces baseline"
