#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet delete deployment debug-tools

kubectl -n starfleet patch deployment shuttle -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s

kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
