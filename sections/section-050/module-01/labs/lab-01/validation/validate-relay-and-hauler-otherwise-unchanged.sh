#!/usr/bin/env bash
# Check: the Deployments stay scaled to zero and the hauler image is unchanged.
set -uo pipefail
fail=0

for name in relay hauler; do
  replicas="$(kubectl -n dockyard get deployment "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  if [ "$replicas" != "0" ]; then
    echo "FAIL: deployment ${name} must stay at 0 replicas (found '${replicas}')"
    fail=1
  fi
done

hauler_image="$(kubectl -n dockyard get deployment hauler -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$hauler_image" != "registry.starfleet.example/fleet/hauler:2.4" ]; then
  echo "FAIL: the hauler image changed (found '${hauler_image}')"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: both Deployments keep 0 replicas and the hauler image is unchanged"
fi
exit "$fail"
