#!/usr/bin/env bash
# Check: every egress rule of the policies that select courier is either a
# rule to scribe on TCP 8080 or a rule to kube-system on port 53. Rejects an
# open egress rule, a missing DNS rule and extra destinations.
set -uo pipefail

policies="$(kubectl -n annex get networkpolicy -o json 2>/dev/null)" || policies=""
if [ -z "$policies" ]; then
  echo "FAIL: could not read NetworkPolicies in annex"
  exit 1
fi

selected="$(echo "$policies" | jq '[.items[]
  | select(((.spec.policyTypes // []) | index("Egress")) != null)
  | select(((.spec.podSelector.matchLabels // {}) == {} and (.spec.podSelector.matchExpressions // []) == []) or .spec.podSelector.matchLabels.app == "courier")]')"
if [ "$(echo "$selected" | jq 'length')" -lt 1 ]; then
  echo "FAIL: no Egress policy selects the courier pods"
  exit 1
fi
rules="$(echo "$selected" | jq '[.[] | (.spec.egress // [])[]]')"

defs='
def is_scribe: (.podSelector.matchLabels.app == "scribe") and (.namespaceSelector == null) and (.ipBlock == null);
def is_dns: (.namespaceSelector.matchLabels["kubernetes.io/metadata.name"] == "kube-system") and (.ipBlock == null);
def tcp_8080: ((.ports // []) | length) > 0 and all((.ports // [])[]; ((.protocol // "TCP") == "TCP") and (.port == 8080 or .port == "http") and .endPort == null);
def dns_ports: ((.ports // []) | length) > 0 and all((.ports // [])[]; ((.protocol // "TCP") == "TCP" or .protocol == "UDP") and .port == 53 and .endPort == null);
def scribe_rule: ((.to // []) | length) > 0 and all((.to // [])[]; is_scribe) and tcp_8080;
def dns_rule: ((.to // []) | length) > 0 and all((.to // [])[]; is_dns) and dns_ports;
'

fail=0
if [ "$(echo "$rules" | jq "$defs [.[] | select((scribe_rule or dns_rule) | not)] | length")" -ne 0 ]; then
  echo "FAIL: an egress rule allows a destination or port other than scribe on 8080 and DNS on 53"
  fail=1
fi
if [ "$(echo "$rules" | jq "$defs [.[] | select(scribe_rule)] | length")" -lt 1 ]; then
  echo "FAIL: no egress rule allows scribe on TCP 8080"
  fail=1
fi
if [ "$(echo "$rules" | jq "$defs [.[] | select(dns_rule) | .ports[] | select(.protocol == \"UDP\")] | length")" -lt 1 ]; then
  echo "FAIL: no egress rule allows DNS (UDP 53) to the kube-system namespace"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: courier may send only to scribe on 8080 and to DNS on 53"
fi
exit "$fail"
