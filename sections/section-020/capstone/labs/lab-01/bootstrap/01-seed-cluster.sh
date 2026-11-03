#!/usr/bin/env bash
# Starting state for the capstone. Environment only: the outpost namespace
# with the exposure paths described in manifests/lab-start.yaml. The learner
# fixes it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in drifter drifter-hostmount; do
  kubectl -n outpost rollout status "deployment/$name" --timeout=180s
done
echo "[lab] Ready."
