#!/usr/bin/env bash
# Check: the ledger rollout is complete, and scout, probe, shuttle and drifter
# are still ready with their original images.
set -uo pipefail

fail=0

ledger="$(kubectl -n starfleet get deployment ledger -o json 2>/dev/null)" || {
  echo "FAIL: the ledger Deployment does not exist"
  exit 1
}
if ! echo "$ledger" | jq -e '(.status.updatedReplicas // 0) == .spec.replicas and (.status.availableReplicas // 0) >= 1 and (.status.replicas // 0) == .spec.replicas' >/dev/null 2>&1; then
  echo "FAIL: the ledger rollout is not complete or has no available replica"
  fail=1
fi

check_unchanged() {
  local namespace="$1" name="$2" image="$3"
  local json
  json="$(kubectl -n "$namespace" get deployment "$name" -o json 2>/dev/null)" || {
    echo "FAIL: the Deployment $name in $namespace does not exist"
    fail=1
    return
  }
  if ! echo "$json" | jq -e --arg image "$image" '(.status.availableReplicas // 0) >= 1 and ([.spec.template.spec.containers[].image] == [$image])' >/dev/null 2>&1; then
    echo "FAIL: $name in $namespace is not available with the image $image"
    fail=1
  fi
}
check_unchanged starfleet scout ghcr.io/stefanprodan/podinfo:6.15.0
check_unchanged starfleet probe mccutchen/go-httpbin:2.25.0
check_unchanged starfleet shuttle curlimages/curl:8.22.0
check_unchanged outpost drifter curlimages/curl:8.22.0

if [ "$fail" -eq 0 ]; then
  echo "PASS: ledger is rolled out and the other workloads are unchanged"
fi
exit "$fail"
