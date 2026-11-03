#!/usr/bin/env bash
# Check: the ledger and loader service accounts do not mount tokens, and no
# Deployment in depot forces the mount back on with a pod field set to true.
set -uo pipefail

fail=0
for account in ledger loader; do
  value="$(kubectl -n depot get serviceaccount "$account" -o json 2>/dev/null | jq -r '.automountServiceAccountToken // "unset"')"
  if [ "$value" != "false" ]; then
    echo "FAIL: service account $account has automountServiceAccountToken $value"
    fail=1
  fi
done

forced="$(kubectl -n depot get deployments -o json 2>/dev/null | jq '[.items[] | select(.spec.template.spec.automountServiceAccountToken == true)] | length')"
if [ "${forced:-1}" -ne 0 ]; then
  echo "FAIL: a Deployment in depot sets automountServiceAccountToken to true on its pods"
  fail=1
fi

images="$(kubectl -n depot get deployments -o json 2>/dev/null | jq -r '[.items[] | .metadata.name + "=" + .spec.template.spec.containers[0].image] | sort | join(",")')"
if [ "$images" != "ledger=mccutchen/go-httpbin:2.25.0,loader=curlimages/curl:8.22.0" ]; then
  echo "FAIL: the Deployments in depot must keep their names and images"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the ledger and loader service accounts do not mount tokens"
fi
exit "$fail"
