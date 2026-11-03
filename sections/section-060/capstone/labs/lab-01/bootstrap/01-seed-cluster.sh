#!/usr/bin/env bash
# Starting state for the capstone. Environment only: the orbit namespace with
# the beacon workload and its weaknesses. The learner fixes them.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n orbit rollout status deployment/beacon --timeout=180s
echo "[lab] Ready."
