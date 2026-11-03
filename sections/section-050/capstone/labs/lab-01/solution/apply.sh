#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
digest="$(kubectl -n shipyard get configmap release-record -o jsonpath='{.data.cargo-digest}')"
kubectl -n shipyard set image deployment/cargo "cargo=ghcr.io/stefanprodan/podinfo@${digest}"
echo "[solution] Applied."
