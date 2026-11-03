#!/usr/bin/env bash
# Check: the LimitRange container-defaults has a Container limit with the
# default memory request and limit from the task.
set -uo pipefail

json="$(kubectl -n starfleet get limitrange container-defaults -o json 2>/dev/null)" || {
  echo "FAIL: the LimitRange container-defaults does not exist in starfleet"
  exit 1
}

if ! echo "$json" | jq -e '[.spec.limits[]? | select(.type == "Container" and .defaultRequest.memory == "32Mi" and .default.memory == "64Mi")] | length == 1' >/dev/null 2>&1; then
  echo "FAIL: container-defaults needs a Container limit with defaultRequest memory 32Mi and default memory 64Mi"
  exit 1
fi

echo "PASS: container-defaults sets the default memory request and limit"
