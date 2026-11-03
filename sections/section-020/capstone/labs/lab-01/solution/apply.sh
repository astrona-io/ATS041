#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n outpost patch deployment drifter -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n outpost rollout status deployment/drifter --timeout=180s
kubectl apply -f "$DIR/solution.yaml"
kubectl delete clusterrolebinding drifter-admin
kubectl delete clusterrolebinding outpost-public-view
kubectl -n outpost delete deployment drifter-hostmount
kubectl label --overwrite namespace outpost pod-security.kubernetes.io/enforce=baseline
echo "[solution] Applied."
