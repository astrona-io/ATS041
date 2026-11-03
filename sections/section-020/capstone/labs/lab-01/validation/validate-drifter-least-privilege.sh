#!/usr/bin/env bash
# Check: behaviour. The drifter service account has no cluster-wide power and
# no Secret access, and it can still get and list ConfigMaps in outpost.
set -uo pipefail

identity="system:serviceaccount:outpost:drifter"
fail=0

for question in "'*' '*'" "delete nodes" "get secrets -n outpost" "get secrets --all-namespaces"; do
  # shellcheck disable=SC2086
  answer="$(eval kubectl auth can-i $question --as="$identity" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: drifter can still do '$question': answer '$answer'"
    fail=1
  fi
done

for verb in get list; do
  answer="$(kubectl auth can-i "$verb" configmaps -n outpost --as="$identity" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: drifter cannot $verb ConfigMaps in outpost: answer '$answer'"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter reads ConfigMaps in outpost and has no cluster-wide power"
fi
exit "$fail"
