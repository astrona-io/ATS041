#!/usr/bin/env bash
# Testing hook: wait until the API server rejects a Deployment without a
# memory limit in orbit, so the validation scripts do not run too early.
set -uo pipefail

for attempt in $(seq 1 60); do
  if ! kubectl -n orbit create deployment grader-wait --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server >/dev/null 2>&1; then
    echo "[testing] The binding is active."
    exit 0
  fi
  sleep 1
done
echo "[testing] The binding did not become active in 60 seconds."
exit 1
