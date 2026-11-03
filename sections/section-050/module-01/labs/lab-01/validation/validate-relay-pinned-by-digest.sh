#!/usr/bin/env bash
# Check: the relay Deployment uses ghcr.io/stefanprodan/podinfo@<digest from
# the release record>, with no tag.
set -uo pipefail

digest="$(kubectl -n dockyard get configmap release-record -o jsonpath='{.data.relay-digest}' 2>/dev/null || true)"
image="$(kubectl -n dockyard get deployment relay -o jsonpath='{.spec.template.spec.containers[?(@.name=="relay")].image}' 2>/dev/null || true)"
expected="ghcr.io/stefanprodan/podinfo@${digest}"

if [ -z "$digest" ]; then
  echo "FAIL: the release-record ConfigMap or its relay-digest key is missing"
  exit 1
fi
if [ "$image" != "$expected" ]; then
  echo "FAIL: relay image is '${image}', expected '${expected}'"
  exit 1
fi
echo "PASS: relay uses the recorded digest and no tag"
