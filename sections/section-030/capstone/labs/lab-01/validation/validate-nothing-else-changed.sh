#!/usr/bin/env bash
# Check: starfleet and outpost carry no Pod Security labels, no binding of
# require-memory-limits selects them by namespace name label, and scout runs.
set -uo pipefail

fail=0

for namespace in starfleet outpost; do
  labels="$(kubectl get namespace "$namespace" -o json | jq -r '.metadata.labels | keys[] | select(startswith("pod-security.kubernetes.io"))' || true)"
  if [ -n "$labels" ]; then
    echo "FAIL: $namespace has Pod Security labels: $labels"
    fail=1
  fi
done

# A binding with no namespaceSelector, or one that has matchExpressions, would
# widen the scope. Only a selector on the orbit name label is accepted.
wide="$(kubectl get validatingadmissionpolicybindings -o json | jq -r '
  .items[]
  | select(.spec.policyName == "require-memory-limits")
  | select((.spec.matchResources.namespaceSelector.matchLabels["kubernetes.io/metadata.name"] // "") != "orbit")
  | .metadata.name' || true)"
if [ -n "$wide" ]; then
  echo "FAIL: these bindings do not select only orbit by name: $wide"
  fail=1
fi

available="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ -z "$available" ] || [ "$available" -lt 1 ]; then
  echo "FAIL: scout in starfleet has no available replica"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: starfleet and outpost are unchanged and scout runs"
fi
exit "$fail"
