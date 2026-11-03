#!/usr/bin/env bash
# Check: a ValidatingAdmissionPolicy that matches pods exists, with failurePolicy
# Fail, and a binding for it has the Deny action and a namespace selector.
set -uo pipefail
fail=0

policy="$(kubectl get validatingadmissionpolicy require-image-digest -o json 2>/dev/null || true)"
if [ -z "$policy" ]; then
  echo "FAIL: ValidatingAdmissionPolicy require-image-digest does not exist"
  exit 1
fi
matches_pods="$(echo "$policy" | jq -r '[.spec.matchConstraints.resourceRules[]? | select((.resources // []) | index("pods"))] | length')"
if [ "$matches_pods" = "0" ]; then
  echo "FAIL: the policy does not match the pods resource"
  fail=1
fi
failure_policy="$(echo "$policy" | jq -r '.spec.failurePolicy // "Fail"')"
if [ "$failure_policy" != "Fail" ]; then
  echo "FAIL: the policy failurePolicy must be Fail (found ${failure_policy})"
  fail=1
fi
scoped="$(kubectl get validatingadmissionpolicybinding -o json 2>/dev/null | jq -r '[.items[] | select(.spec.policyName == "require-image-digest") | select((.spec.validationActions // []) | index("Deny")) | select(.spec.matchResources.namespaceSelector != null)] | length')"
if [ "$scoped" = "0" ]; then
  echo "FAIL: no binding for require-image-digest has the Deny action and a namespaceSelector"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: policy require-image-digest and a scoped denying binding exist"
fi
exit "$fail"
