#!/usr/bin/env bash
# Starting state for the isolation lab. Environment only: it creates the
# over-privileged `relay` Deployment that the learner must harden.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n outpost rollout status deployment/relay --timeout=180s
echo "[lab] Ready."
