#!/usr/bin/env bash
# Check: the Deployment is rolled out and its running pods carry the fixed
# settings. Proves the change reached real pods and the workload still runs.
set -uo pipefail

dep="$(kubectl -n outpost get deployment relay -o json 2>/dev/null)" || dep=""
if [ -z "$dep" ]; then
  echo "FAIL: Deployment relay not found in outpost"
  exit 1
fi

fail=0
desired="$(echo "$dep" | jq '.spec.replicas // 1')"
ready="$(echo "$dep" | jq '.status.readyReplicas // 0')"
updated="$(echo "$dep" | jq '.status.updatedReplicas // 0')"
total="$(echo "$dep" | jq '.status.replicas // 0')"
if [ "$ready" -ne "$desired" ] || [ "$updated" -ne "$desired" ] || [ "$total" -ne "$desired" ]; then
  echo "FAIL: the rollout is not finished (desired $desired, ready $ready, updated $updated, total $total)"
  exit 1
fi

if [ "$(echo "$dep" | jq -r '.spec.template.metadata.labels.app // ""')" != "relay" ]; then
  echo "FAIL: the pod template must keep the label app=relay"
  fail=1
fi
if [ "$(echo "$dep" | jq -r '.spec.template.spec.containers[0].image')" != "curlimages/curl:8.22.0" ]; then
  echo "FAIL: relay must keep the image curlimages/curl:8.22.0"
  fail=1
fi
if [ "$(echo "$dep" | jq '[.spec.template.spec.containers[] | select(.securityContext.readOnlyRootFilesystem != true)] | length')" -ne 0 ]; then
  echo "FAIL: relay must run with a read-only root filesystem"
  fail=1
fi

pods="$(kubectl -n outpost get pods -l app=relay -o json 2>/dev/null)" || pods=""
active="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null)] | length')"
if [ "$active" -lt 1 ]; then
  echo "FAIL: no running relay pod found"
  exit 1
fi
bad="$(echo "$pods" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | select((.spec.hostPID // false) or (.spec.hostNetwork // false) or (.spec.hostIPC // false) or ([.spec.containers[].securityContext.privileged] | any(. == true)) or ([(.spec.volumes // [])[] | select(.hostPath != null)] | length > 0))] | length')"
if [ "$bad" -ne 0 ]; then
  echo "FAIL: a running relay pod still has host access"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay is rolled out and its pods have no host access"
fi
exit "$fail"
