#!/usr/bin/env bash
# Check: a LimitRange in depot gives containers memory and CPU defaults and a
# memory maximum. Also asks the API server (server-side dry run, nothing is
# created) to admit a pod without resources and checks that it got defaults.
set -uo pipefail

ranges="$(kubectl -n depot get limitrange -o json 2>/dev/null)" || ranges=""
if [ -z "$ranges" ]; then
  echo "FAIL: could not read LimitRanges in depot"
  exit 1
fi

ok="$(echo "$ranges" | jq '[.items[].spec.limits[]
  | select(.type == "Container")
  | select(.default.memory != null)
  | select(.defaultRequest.memory != null)
  | select(.defaultRequest.cpu != null)
  | select(.max.memory != null)] | length')"
if [ "$ok" -lt 1 ]; then
  echo "FAIL: no Container entry sets default.memory, defaultRequest.cpu, defaultRequest.memory and max.memory"
  exit 1
fi

pod="$(kubectl -n depot run limitrange-check --image=curlimages/curl:8.22.0 --dry-run=server -o json --command -- sleep 1 2>&1)" || {
  echo "FAIL: the API server rejected a pod without resources in depot: $pod"
  exit 1
}
limit="$(echo "$pod" | jq -r '.spec.containers[0].resources.limits.memory // ""')"
request="$(echo "$pod" | jq -r '.spec.containers[0].resources.requests.memory // ""')"
if [ -z "$limit" ] || [ -z "$request" ]; then
  echo "FAIL: a pod without resources did not receive memory defaults"
  exit 1
fi
echo "PASS: depot gives containers memory and CPU defaults and a memory maximum"
