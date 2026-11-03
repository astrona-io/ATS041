#!/usr/bin/env bash
# Starting state for the capstone. Environment only: it creates the relay
# namespace and its weaknesses. It does not create any control the learner must add.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n relay rollout status deployment/beacon --timeout=180s
kubectl -n relay wait --for=condition=Ready pod/stray --timeout=180s
echo "[lab] Ready."
