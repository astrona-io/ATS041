#!/usr/bin/env bash
# Check: relay pods do not get a service account token. The pod field wins
# over the service account field; if the pod field is unset, the service
# account decides.
set -uo pipefail

pod_value="$(kubectl -n outpost get deployment relay -o json 2>/dev/null | jq -r '.spec.template.spec.automountServiceAccountToken // "unset"')"
sa_value="$(kubectl -n outpost get serviceaccount relay -o json 2>/dev/null | jq -r '.automountServiceAccountToken // "unset"')"

if [ "$pod_value" = "false" ]; then
  echo "PASS: the relay pod template sets automountServiceAccountToken to false"
  exit 0
fi
if [ "$pod_value" = "unset" ] && [ "$sa_value" = "false" ]; then
  echo "PASS: the relay service account sets automountServiceAccountToken to false"
  exit 0
fi
echo "FAIL: relay pods still receive a token (pod field: $pod_value, service account field: $sa_value)"
exit 1
