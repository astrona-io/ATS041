#!/usr/bin/env bash
# Starting state for the node and data exposure lab. Environment only: the
# Starfleet workloads plus four exposure paths (an unauthenticated view
# binding, a hostPath Deployment, a Secret readable by scout). The learner
# fixes it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/exposure.yaml"

for name in scout probe shuttle node-inspector; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
