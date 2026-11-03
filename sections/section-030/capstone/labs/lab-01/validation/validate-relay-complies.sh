#!/usr/bin/env bash
# Check: relay sets a memory limit on every container and automount false in
# the pod template, no running relay pod mounts the token, and it is available.
set -uo pipefail

fail=0

if ! kubectl -n orbit get deployment relay >/dev/null 2>&1; then
  echo "FAIL: the relay Deployment is missing"
  exit 1
fi

missing="$(kubectl -n orbit get deployment relay -o json \
  | jq -r '.spec.template.spec.containers[] | select((.resources.limits.memory // null) == null) | .name' || true)"
if [ -n "$missing" ]; then
  echo "FAIL: relay containers without a memory limit: $missing"
  fail=1
fi

setting="$(kubectl -n orbit get deployment relay -o json | jq -r '.spec.template.spec.automountServiceAccountToken // "unset"')"
if [ "$setting" != "false" ]; then
  echo "FAIL: relay pod template has automountServiceAccountToken '$setting', expected false"
  fail=1
fi

mounting="$(kubectl -n orbit get pods -l app=relay -o json \
  | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | select(any(.spec.containers[].volumeMounts[]?; .mountPath == "/var/run/secrets/kubernetes.io/serviceaccount")) | .metadata.name' || true)"
if [ -n "$mounting" ]; then
  echo "FAIL: these relay pods still mount the token: $mounting"
  fail=1
fi

available="$(kubectl -n orbit get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ -z "$available" ] || [ "$available" -lt 1 ]; then
  echo "FAIL: relay has no available replica"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay has a memory limit, mounts no token and is available"
fi
exit "$fail"
