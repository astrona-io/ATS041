#!/usr/bin/env bash
# Starting state for the controls lab. Environment only: the Starfleet
# workloads, a privileged debug-tools Deployment and no Pod Security labels.
# The learner fixes it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

for name in scout probe shuttle debug-tools; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
