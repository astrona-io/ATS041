#!/usr/bin/env bash
# Check: state. Graded by the NetworkPolicy spec, not by traffic, because the
# result must not depend on the network plugin. A policy that selects all pods
# in outpost must allow 0.0.0.0/0 except the metadata address, and no policy
# that selects all pods may allow egress to every destination.
set -uo pipefail

policies="$(kubectl -n outpost get networkpolicy -o json 2>/dev/null || echo '{"items":[]}')"

good="$(echo "$policies" | jq '
  [.items[]
   | select((.spec.podSelector // {}) == {})
   | select((.spec.policyTypes // []) | index("Egress"))
   | .spec.egress[]?
   | .to[]?
   | .ipBlock
   | select(. != null and .cidr == "0.0.0.0/0")
   | select((.except // []) | any(. == "169.254.169.254/32" or . == "169.254.169.0/24" or . == "169.254.0.0/16"))
  ] | length')"

open_rules="$(echo "$policies" | jq '
  [.items[]
   | select((.spec.podSelector // {}) == {})
   | select((.spec.policyTypes // []) | index("Egress"))
   | .spec.egress[]?
   | select(
       ((.to // []) | length) == 0
       or ((.to // []) | any(.ipBlock != null and .ipBlock.cidr == "0.0.0.0/0"
            and ((.ipBlock.except // []) | any(. == "169.254.169.254/32" or . == "169.254.169.0/24" or . == "169.254.0.0/16") | not)))
     )
  ] | length')"

fail=0
if [ "${good:-0}" -lt 1 ]; then
  echo "FAIL: no Egress NetworkPolicy selecting all pods in outpost allows 0.0.0.0/0 except 169.254.169.254/32"
  fail=1
fi
if [ "${open_rules:-0}" -gt 0 ]; then
  echo "FAIL: an egress rule on a policy that selects all pods still allows the metadata address"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the metadata address is excluded from egress and other destinations stay allowed"
fi
exit "$fail"
