#!/usr/bin/env bash
# Check: the beacon rollout is complete, every live beacon pod has the container
# settings and no token volume, and the Service has a ready endpoint.
set -uo pipefail

fail=0

deployment="$(kubectl -n orbit get deployment beacon -o json 2>/dev/null)" || {
  echo "FAIL: the beacon Deployment does not exist"
  exit 1
}
if ! echo "$deployment" | jq -e '(.status.updatedReplicas // 0) == .spec.replicas and (.status.availableReplicas // 0) >= 1 and (.status.replicas // 0) == .spec.replicas' >/dev/null 2>&1; then
  echo "FAIL: the beacon rollout is not complete or has no available replica"
  fail=1
fi

pods="$(kubectl -n orbit get pods -l app=beacon -o json 2>/dev/null)"
if ! echo "$pods" | jq -e '
  (.items | length) >= 1
  and ([.items[] | select(.metadata.deletionTimestamp == null)
        | select((.spec.containers[0].securityContext.readOnlyRootFilesystem // false) != true
                 or (.spec.containers[0].securityContext.allowPrivilegeEscalation // true) != false
                 or ([.spec.volumes[]? | select(.name | startswith("kube-api-access"))] | length) > 0)] | length == 0)' >/dev/null 2>&1; then
  echo "FAIL: a live beacon pod misses the container settings or still has an API token volume"
  fail=1
fi

endpoints="$(kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon -o json 2>/dev/null | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null || echo 0)"
if [ "${endpoints:-0}" -lt 1 ]; then
  echo "FAIL: the Service beacon has no ready endpoint"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon runs with the settings and its Service has an endpoint"
fi
exit "$fail"
