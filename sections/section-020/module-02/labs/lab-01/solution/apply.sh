#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl delete clusterrolebinding public-view
kubectl -n starfleet delete deployment node-inspector
kubectl label --overwrite namespace starfleet pod-security.kubernetes.io/enforce=baseline
kubectl apply -f "$DIR/solution.yaml"
kubectl -n starfleet delete rolebinding scout-secrets
echo "[solution] Applied."
