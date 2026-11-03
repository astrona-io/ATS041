#!/usr/bin/env bash
# Check: a policy that selects every pod in depot, covers Ingress and allows
# nothing. Rejects an Egress-only policy and a policy that selects only some
# pods.
set -uo pipefail

policies="$(kubectl -n depot get networkpolicy -o json 2>/dev/null)" || policies=""
if [ -z "$policies" ]; then
  echo "FAIL: could not read NetworkPolicies in depot"
  exit 1
fi

count="$(echo "$policies" | jq '[.items[]
  | select((.spec.podSelector.matchLabels // {}) == {} and (.spec.podSelector.matchExpressions // []) == [])
  | select(((.spec.policyTypes // ["Ingress"]) | index("Ingress")) != null)
  | select(((.spec.ingress // []) | length) == 0)] | length')"

if [ "$count" -lt 1 ]; then
  echo "FAIL: no policy in depot selects every pod, covers Ingress and has no ingress rule"
  exit 1
fi
echo "PASS: depot has a default deny ingress policy"
