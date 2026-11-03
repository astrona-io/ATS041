#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete clusterrolebinding beacon-admin
kubectl -n relay delete pod stray
kubectl apply -f "$DIR/solution.yaml"
kubectl -n relay rollout status deployment/beacon --timeout=180s
echo "[solution] Applied."
