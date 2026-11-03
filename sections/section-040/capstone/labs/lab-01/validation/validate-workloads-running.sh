#!/usr/bin/env bash
# Check: scribe and courier are rolled out with their original names, labels
# and images, and the live courier pods carry no host access. Proves the
# changes reached real pods and the workloads still run.
set -uo pipefail

fail=0
check_rollout() {
  local name="$1" image="$2"
  local dep
  dep="$(kubectl -n annex get deployment "$name" -o json 2>/dev/null)" || dep=""
  if [ -z "$dep" ]; then
    echo "FAIL: Deployment $name not found in annex"
    fail=1
    return
  fi
  local desired ready updated total
  desired="$(echo "$dep" | jq '.spec.replicas // 1')"
  ready="$(echo "$dep" | jq '.status.readyReplicas // 0')"
  updated="$(echo "$dep" | jq '.status.updatedReplicas // 0')"
  total="$(echo "$dep" | jq '.status.replicas // 0')"
  if [ "$ready" -ne "$desired" ] || [ "$updated" -ne "$desired" ] || [ "$total" -ne "$desired" ]; then
    echo "FAIL: $name is not rolled out (desired $desired, ready $ready, updated $updated, total $total)"
    fail=1
  fi
  if [ "$(echo "$dep" | jq -r '.spec.template.metadata.labels.app // ""')" != "$name" ]; then
    echo "FAIL: $name must keep the pod label app=$name"
    fail=1
  fi
  if [ "$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')" != "$image" ]; then
    echo "FAIL: $name must keep the image $image"
    fail=1
  fi
}

check_rollout scribe mccutchen/go-httpbin:2.25.0
check_rollout courier curlimages/curl:8.22.0

pods="$(kubectl -n annex get pods -l app=courier -o json 2>/dev/null)" || pods=""
active="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
if [ "${active:-0}" -lt 1 ]; then
  echo "FAIL: no running courier pod found"
  fail=1
else
  bad="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | select((.spec.hostNetwork // false) or (.spec.hostPID // false) or ([.spec.containers[].securityContext.privileged] | any(. == true)) or ([(.spec.volumes // [])[] | select(.hostPath != null)] | length > 0))] | length')"
  if [ "$bad" -ne 0 ]; then
    echo "FAIL: a running courier pod still has host access"
    fail=1
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scribe and courier are rolled out and courier has no host access"
fi
exit "$fail"
