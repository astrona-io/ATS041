#!/usr/bin/env bash
# Check: annex has a default deny ingress policy, and the policies that select
# scribe allow only courier (same namespace) on TCP 8080.
set -uo pipefail

policies="$(kubectl -n annex get networkpolicy -o json 2>/dev/null)" || policies=""
if [ -z "$policies" ]; then
  echo "FAIL: could not read NetworkPolicies in annex"
  exit 1
fi

fail=0
deny="$(echo "$policies" | jq '[.items[]
  | select((.spec.podSelector.matchLabels // {}) == {} and (.spec.podSelector.matchExpressions // []) == [])
  | select(((.spec.policyTypes // ["Ingress"]) | index("Ingress")) != null)
  | select(((.spec.ingress // []) | length) == 0)] | length')"
if [ "$deny" -lt 1 ]; then
  echo "FAIL: no default deny ingress policy that selects every pod in annex"
  fail=1
fi

rules="$(echo "$policies" | jq '[.items[] | select(.spec.podSelector.matchLabels.app == "scribe") | (.spec.ingress // [])[]]')"
if [ "$(echo "$rules" | jq 'length')" -lt 1 ]; then
  echo "FAIL: no policy that selects app=scribe has an ingress rule"
  exit 1
fi
if [ "$(echo "$rules" | jq '[.[] | select(((.from // []) | length) == 0 or ((.ports // []) | length) == 0)] | length')" -ne 0 ]; then
  echo "FAIL: an ingress rule for scribe has no from list or no ports"
  fail=1
fi
if [ "$(echo "$rules" | jq '[.[] | (.ports // [])[] | select(((.protocol // "TCP") != "TCP") or ((.port != 8080) and (.port != "http")) or (.endPort != null))] | length')" -ne 0 ]; then
  echo "FAIL: scribe must accept only TCP port 8080"
  fail=1
fi
defs='def is_courier: (.podSelector.matchLabels.app == "courier") and (.namespaceSelector == null) and (.ipBlock == null); [.[] | (.from // [])[]]'
if [ "$(echo "$rules" | jq "$defs | [.[] | select(is_courier)] | length")" -lt 1 ]; then
  echo "FAIL: no peer allows the courier pods"
  fail=1
fi
if [ "$(echo "$rules" | jq "$defs | [.[] | select(is_courier | not)] | length")" -ne 0 ]; then
  echo "FAIL: scribe accepts a source other than courier"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: annex denies ingress by default and scribe accepts only courier on 8080"
fi
exit "$fail"
