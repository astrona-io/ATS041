#!/usr/bin/env bash
# Starting state for the isolation capstone. Environment only: it creates the
# workloads. It creates no NetworkPolicy, ResourceQuota or LimitRange.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n annex rollout status deployment/scribe --timeout=180s
kubectl -n annex rollout status deployment/courier --timeout=180s
echo "[lab] Ready."
