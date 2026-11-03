#!/usr/bin/env bash
# Check: the hauler ServiceAccount lists registry-creds in imagePullSecrets.
set -uo pipefail

found="$(kubectl -n dockyard get serviceaccount hauler -o json 2>/dev/null | jq -r '[.imagePullSecrets[]?.name] | index("registry-creds") // empty')"
if [ -z "$found" ]; then
  echo "FAIL: the hauler ServiceAccount does not list registry-creds in imagePullSecrets"
  exit 1
fi
echo "PASS: the hauler ServiceAccount lists registry-creds"
