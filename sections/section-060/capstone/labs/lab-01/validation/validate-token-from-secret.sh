#!/usr/bin/env bash
# Check: the Secret beacon-credentials holds the original token, API_TOKEN comes
# from it through secretKeyRef, and the original value is nowhere in the pod template.
set -uo pipefail

fail=0

encoded="$(kubectl -n orbit get secret beacon-credentials -o jsonpath='{.data.token}' 2>/dev/null || true)"
value="$(printf '%s' "$encoded" | base64 -d 2>/dev/null || true)"
if [ -z "$encoded" ] || [ "$value" != "beacon-token-9" ]; then
  echo "FAIL: the Secret beacon-credentials must have the key 'token' with the original token"
  fail=1
fi

template="$(kubectl -n orbit get deployment beacon -o json 2>/dev/null | jq -c '.spec.template')" || template=""
if [ -z "$template" ] || [ "$template" = "null" ]; then
  echo "FAIL: the beacon Deployment does not exist"
  exit 1
fi

if ! echo "$template" | jq -e '[.spec.containers[] | select(.name=="beacon") | .env[]? | select(.name=="API_TOKEN" and .valueFrom.secretKeyRef.name=="beacon-credentials" and .valueFrom.secretKeyRef.key=="token")] | length == 1' >/dev/null 2>&1; then
  echo "FAIL: API_TOKEN must use secretKeyRef to the key 'token' of beacon-credentials"
  fail=1
fi
if echo "$template" | jq -e 'tostring | contains("beacon-token-9")' >/dev/null 2>&1; then
  echo "FAIL: the original token is still written in the pod template"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the token comes from beacon-credentials and is not in the pod template"
fi
exit "$fail"
