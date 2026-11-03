#!/usr/bin/env bash
# Check: behaviour. An unauthenticated caller cannot read pods or Secrets in
# starfleet, and the built-in public-info-viewer binding is still there (the
# fix must not delete the cluster's own bindings).
set -uo pipefail

fail=0

for resource in pods secrets; do
  answer="$(kubectl auth can-i list "$resource" -n starfleet --as=system:anonymous --as-group=system:unauthenticated 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: an unauthenticated caller can still list $resource in starfleet: answer '$answer'"
    fail=1
  fi
done

if ! kubectl get clusterrolebinding system:public-info-viewer >/dev/null 2>&1; then
  echo "FAIL: the built-in binding system:public-info-viewer was deleted"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: unauthenticated callers cannot read pods or Secrets"
fi
exit "$fail"
