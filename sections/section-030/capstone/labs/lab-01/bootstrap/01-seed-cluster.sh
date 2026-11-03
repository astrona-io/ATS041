#!/usr/bin/env bash
# Starting state for the capstone. Environment only: the new namespace orbit
# with a relay Deployment and a privileged beacon-debug Deployment, scout in
# starfleet, and the policy require-memory-limits without a binding.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n starfleet rollout status deployment/scout --timeout=180s
for name in relay beacon-debug; do
  kubectl -n orbit rollout status "deployment/$name" --timeout=180s
done
echo "[lab] Ready."
