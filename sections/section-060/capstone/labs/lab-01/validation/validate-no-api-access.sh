#!/usr/bin/env bash
# Check: the beacon service account exists, may not get, list or watch Secrets
# in orbit (answer from the API server), and the pod template does not mount a token.
set -uo pipefail

fail=0

if ! kubectl -n orbit get serviceaccount beacon >/dev/null 2>&1; then
  echo "FAIL: the service account beacon does not exist"
  exit 1
fi

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" secrets -n orbit --as=system:serviceaccount:orbit:beacon 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: beacon can still '$verb' secrets in orbit (can-i answered '${answer}')"
    fail=1
  fi
done

if ! kubectl -n orbit get deployment beacon -o json 2>/dev/null | jq -e '.spec.template.spec.automountServiceAccountToken == false' >/dev/null 2>&1; then
  echo "FAIL: automountServiceAccountToken must be false in the beacon pod template"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon cannot read Secrets and gets no API token"
fi
exit "$fail"
