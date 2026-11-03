#!/usr/bin/env bash
# Check: no binding gives the shuttle service account cluster-admin, and the
# service account still exists. Rejects deleting the service account.
set -uo pipefail

if ! kubectl -n starfleet get serviceaccount shuttle >/dev/null 2>&1; then
  echo "FAIL: the service account shuttle was deleted; keep it and remove only the grant"
  exit 1
fi

found="$(kubectl get clusterrolebindings,rolebindings -A -o json | jq -r '
  .items[]
  | select(.roleRef.name == "cluster-admin")
  | select(any(.subjects[]?; .kind == "ServiceAccount" and .name == "shuttle"))
  | .metadata.name')"
if [ -n "$found" ]; then
  echo "FAIL: shuttle is still bound to cluster-admin by: $found"
  exit 1
fi

answer="$(kubectl auth can-i list secrets -n starfleet --as=system:serviceaccount:starfleet:shuttle 2>/dev/null || true)"
if [ "$answer" != "no" ]; then
  echo "FAIL: shuttle can still list Secrets in starfleet (can-i answered '$answer')"
  exit 1
fi

echo "PASS: shuttle has no cluster-admin grant and cannot list Secrets"
