#!/usr/bin/env bash
# Check: cargo uses ghcr.io/stefanprodan/podinfo@<digest from the release
# record>, with no tag, and stays at zero replicas.
set -uo pipefail

digest="$(kubectl -n shipyard get configmap release-record -o jsonpath='{.data.cargo-digest}' 2>/dev/null || true)"
image="$(kubectl -n shipyard get deployment cargo -o jsonpath='{.spec.template.spec.containers[?(@.name=="cargo")].image}' 2>/dev/null || true)"
replicas="$(kubectl -n shipyard get deployment cargo -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
expected="ghcr.io/stefanprodan/podinfo@${digest}"

if [ -z "$digest" ]; then
  echo "FAIL: the release-record ConfigMap or its cargo-digest key is missing"
  exit 1
fi
if [ "$image" != "$expected" ]; then
  echo "FAIL: cargo image is '${image}', expected '${expected}'"
  exit 1
fi
if [ "$replicas" != "0" ]; then
  echo "FAIL: cargo must stay at 0 replicas (found '${replicas}')"
  exit 1
fi
echo "PASS: cargo uses the recorded digest and stays at 0 replicas"
