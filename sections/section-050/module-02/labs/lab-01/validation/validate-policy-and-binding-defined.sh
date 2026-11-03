#!/usr/bin/env bash
# Check: the ValidatingAdmissionPolicy approved-registries exists, matches
# pods, and a binding for it denies requests.
set -uo pipefail
fail=0

policy="$(kubectl get validatingadmissionpolicy approved-registries -o json 2>/dev/null || true)"
if [ -z "$policy" ]; then
  echo "FAIL: ValidatingAdmissionPolicy approved-registries does not exist"
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
denying="$(kubectl get validatingadmissionpolicybinding -o json 2>/dev/null | jq -r '[.items[] | select(.spec.policyName == "approved-registries") | select((.spec.validationActions // []) | index("Deny"))] | length')"
if [ "$denying" = "0" ]; then
  echo "FAIL: no ValidatingAdmissionPolicyBinding for approved-registries has the Deny action"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: policy approved-registries and a denying binding exist"
fi
exit "$fail"
