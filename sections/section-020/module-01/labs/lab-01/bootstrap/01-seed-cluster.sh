#!/usr/bin/env bash
# Starting state for the infrastructure identity lab. Environment only: the
# Starfleet workloads with the default token mount, a build-runner service
# account bound to cluster-admin, and no NetworkPolicy. The learner fixes it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/access.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
