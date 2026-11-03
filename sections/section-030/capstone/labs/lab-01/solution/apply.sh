#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
# relay is patched before the binding exists, so the update is not blocked.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n orbit delete deployment beacon-debug

kubectl -n orbit patch deployment relay -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false,"containers":[{"name":"relay","resources":{"limits":{"memory":"64Mi"}}}]}}}}'
kubectl -n orbit rollout status deployment/relay --timeout=180s

kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
