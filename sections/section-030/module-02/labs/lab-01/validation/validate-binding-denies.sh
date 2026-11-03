#!/usr/bin/env bash
# Check: a binding of the policy require-memory-limits lists the Deny action.
set -uo pipefail

denying="$(kubectl get validatingadmissionpolicybindings -o json \
  | jq -r '.items[] | select(.spec.policyName == "require-memory-limits") | select(.spec.validationActions | index("Deny")) | .metadata.name' || true)"

if [ -z "$denying" ]; then
  echo "FAIL: no binding of require-memory-limits uses the Deny action"
  exit 1
fi
echo "PASS: binding uses Deny: $denying"
