#!/usr/bin/env bash
# Check: the policies that select ledger allow exactly two sources (loader in
# the same namespace, and shuttle in starfleet), only on TCP 8080. Rejects
# open rules, a namespaceSelector alone, a separate shuttle podSelector (OR
# instead of AND), ipBlock peers and other ports.
set -uo pipefail

policies="$(kubectl -n depot get networkpolicy -o json 2>/dev/null)" || policies=""
if [ -z "$policies" ]; then
  echo "FAIL: could not read NetworkPolicies in depot"
  exit 1
fi

rules="$(echo "$policies" | jq '[.items[] | select(.spec.podSelector.matchLabels.app == "ledger") | (.spec.ingress // [])[]]')"
if [ "$(echo "$rules" | jq 'length')" -lt 1 ]; then
  echo "FAIL: no policy that selects app=ledger has an ingress rule"
  exit 1
fi

fail=0

if [ "$(echo "$rules" | jq '[.[] | select(((.from // []) | length) == 0)] | length')" -ne 0 ]; then
  echo "FAIL: an ingress rule for ledger has no from list, which allows every source"
  fail=1
fi

if [ "$(echo "$rules" | jq '[.[] | select(((.ports // []) | length) == 0)] | length')" -ne 0 ]; then
  echo "FAIL: an ingress rule for ledger lists no port, which allows every port"
  fail=1
fi

if [ "$(echo "$rules" | jq '[.[] | (.ports // [])[] | select(((.protocol // "TCP") != "TCP") or ((.port != 8080) and (.port != "http")) or (.endPort != null))] | length')" -ne 0 ]; then
  echo "FAIL: ledger must accept only TCP port 8080"
  fail=1
fi

defs='def is_loader: (.podSelector.matchLabels.app == "loader") and (.namespaceSelector == null) and (.ipBlock == null);
def is_shuttle: (.podSelector.matchLabels.app == "shuttle") and (.namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "starfleet") and (.ipBlock == null);
[.[] | (.from // [])[]]'

if [ "$(echo "$rules" | jq "$defs | [.[] | select(is_loader)] | length")" -lt 1 ]; then
  echo "FAIL: no peer allows the loader pods of depot"
  fail=1
fi
if [ "$(echo "$rules" | jq "$defs | [.[] | select(is_shuttle)] | length")" -lt 1 ]; then
  echo "FAIL: no single peer combines namespace starfleet and pod label app=shuttle"
  fail=1
fi
if [ "$(echo "$rules" | jq "$defs | [.[] | select((is_loader or is_shuttle) | not)] | length")" -ne 0 ]; then
  echo "FAIL: ledger accepts a source other than loader and shuttle in starfleet"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: ledger accepts only loader and shuttle in starfleet, on TCP 8080"
fi
exit "$fail"
