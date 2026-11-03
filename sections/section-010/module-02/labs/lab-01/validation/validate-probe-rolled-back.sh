#!/usr/bin/env bash
# Check: probe runs the working image again and the rollout is complete.
# Rejects leaving the bad image or deleting the Deployment.
set -uo pipefail

image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ "$image" != "mccutchen/go-httpbin:2.25.0" ]; then
  echo "FAIL: the probe image is '${image}', expected mccutchen/go-httpbin:2.25.0"
  exit 1
fi

if ! kubectl -n starfleet rollout status deployment/probe --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the probe Deployment did not finish rolling out"
  exit 1
fi

echo "PASS: probe is back on the working image and rolled out"
