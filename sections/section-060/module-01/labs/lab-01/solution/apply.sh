#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet delete rolebinding shuttle-secret-reader
kubectl apply -f "$DIR/solution.yaml"
kubectl -n starfleet rollout status deployment/ledger --timeout=180s
echo "[solution] Applied."
