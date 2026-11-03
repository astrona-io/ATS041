#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
digest="$(kubectl -n dockyard get configmap release-record -o jsonpath='{.data.relay-digest}')"
kubectl -n dockyard set image deployment/relay "relay=ghcr.io/stefanprodan/podinfo@${digest}"
echo "[solution] Applied."
