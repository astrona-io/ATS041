#!/usr/bin/env bash
# Check: probe is rolled out, every running probe pod carries the settings (a
# template change that did not roll out fails here), the Service has an
# endpoint, and scout, shuttle and drifter are unchanged.
set -uo pipefail

fail=0

probe="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null)" || {
  echo "FAIL: the probe Deployment does not exist"
  exit 1
}
if ! echo "$probe" | jq -e '(.status.updatedReplicas // 0) == .spec.replicas and (.status.availableReplicas // 0) >= 1 and (.status.replicas // 0) == .spec.replicas' >/dev/null 2>&1; then
  echo "FAIL: the probe rollout is not complete or has no available replica"
  fail=1
fi

pods="$(kubectl -n starfleet get pods -l app=probe -o json 2>/dev/null)"
if ! echo "$pods" | jq -e '
  (.items | length) >= 1
  and ([.items[] | select(.metadata.deletionTimestamp == null)
        | select((.spec.containers[0].securityContext.readOnlyRootFilesystem // false) != true
                 or (.spec.containers[0].securityContext.allowPrivilegeEscalation // true) != false)] | length == 0)' >/dev/null 2>&1; then
  echo "FAIL: a running probe pod does not have readOnlyRootFilesystem true and allowPrivilegeEscalation false"
  fail=1
fi

endpoints="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o json 2>/dev/null | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null || echo 0)"
if [ "${endpoints:-0}" -lt 1 ]; then
  echo "FAIL: the probe Service has no ready endpoint"
  fail=1
fi

check_unchanged() {
  local namespace="$1" name="$2" image="$3"
  local json
  json="$(kubectl -n "$namespace" get deployment "$name" -o json 2>/dev/null)" || {
    echo "FAIL: the Deployment $name in $namespace does not exist"
    fail=1
    return
  }
  if ! echo "$json" | jq -e --arg image "$image" '(.status.availableReplicas // 0) >= 1 and ([.spec.template.spec.containers[].image] == [$image]) and ((.spec.template.spec.containers[0].securityContext // {}) == {})' >/dev/null 2>&1; then
    echo "FAIL: $name in $namespace is not available or was changed"
    fail=1
  fi
}
check_unchanged starfleet scout ghcr.io/stefanprodan/podinfo:6.15.0
check_unchanged starfleet shuttle curlimages/curl:8.22.0
check_unchanged outpost drifter curlimages/curl:8.22.0

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe is rolled out with the settings and the other workloads are unchanged"
fi
exit "$fail"
