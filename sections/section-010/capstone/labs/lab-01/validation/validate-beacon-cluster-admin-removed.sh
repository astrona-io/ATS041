#!/usr/bin/env bash
# Check: no binding gives the beacon service account cluster-admin; the
# service account still exists. Rejects deleting the service account.
set -uo pipefail

if ! kubectl -n relay get serviceaccount beacon >/dev/null 2>&1; then
  echo "FAIL: the service account beacon was deleted; keep it and remove only the grant"
  exit 1
fi

found="$(kubectl get clusterrolebindings,rolebindings -A -o json | jq -r '
  .items[]
  | select(.roleRef.name == "cluster-admin")
  | select(any(.subjects[]?; .kind == "ServiceAccount" and .name == "beacon"))
  | .metadata.name')"
if [ -n "$found" ]; then
  echo "FAIL: beacon is still bound to cluster-admin by: $found"
  exit 1
fi

answer="$(kubectl auth can-i list secrets -n relay --as=system:serviceaccount:relay:beacon 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: beacon can still list Secrets in relay (can-i answered '$answer')"
  exit 1
fi

echo "PASS: beacon has no cluster-admin grant"
