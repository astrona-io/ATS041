#!/usr/bin/env bash
# Check: probe and drifter are still running with their original images, and
# no other service account in starfleet or outpost was given cluster-admin.
set -uo pipefail

fail=0
probe_image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$probe_image" != "mccutchen/go-httpbin:2.25.0" ]; then
  echo "FAIL: probe image is '${probe_image}', expected mccutchen/go-httpbin:2.25.0"
  fail=1
fi
probe_ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${probe_ready:-0}" -lt 1 ]; then
  echo "FAIL: probe has no ready replica"
  fail=1
fi
drifter_ready="$(kubectl -n outpost get deployment drifter -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
if [ "${drifter_ready:-0}" -lt 1 ]; then
  echo "FAIL: drifter has no ready replica"
  fail=1
fi

admins="$(kubectl get clusterrolebindings,rolebindings -A -o json | jq -r '
  .items[]
  | select(.roleRef.name == "cluster-admin")
  | select(any(.subjects[]?; .kind == "ServiceAccount" and (.namespace == "starfleet" or .namespace == "outpost")))
  | .metadata.name')"
if [ -n "$admins" ]; then
  echo "FAIL: a workload service account is still bound to cluster-admin: $admins"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe and drifter are unchanged and no workload has cluster-admin"
fi
exit "$fail"
