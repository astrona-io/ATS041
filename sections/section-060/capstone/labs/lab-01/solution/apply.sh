#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n orbit delete rolebinding beacon-secrets
kubectl apply -f "$DIR/solution.yaml"
kubectl -n orbit rollout status deployment/beacon --timeout=180s
echo "[solution] Applied."
