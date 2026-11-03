#!/usr/bin/env bash
# Check: scout, probe and shuttle are available, shuttle gets HTTP 200 from the
# scout Service, and outpost has no Pod Security labels.
set -uo pipefail

fail=0

for name in scout probe shuttle; do
  available="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
  if [ -z "$available" ] || [ "$available" -lt 1 ]; then
    echo "FAIL: deployment $name in starfleet has no available replica"
    fail=1
  fi
done

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -w '%{http_code}' --max-time 10 http://scout:9898/ 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '$code' from the scout Service, expected 200"
  fail=1
fi

labels="$(kubectl get namespace outpost -o json | jq -r '.metadata.labels | keys[] | select(startswith("pod-security.kubernetes.io"))' || true)"
if [ -n "$labels" ]; then
  echo "FAIL: outpost has Pod Security labels: $labels"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: workloads run, scout answers and outpost is unchanged"
fi
exit "$fail"
