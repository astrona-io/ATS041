#!/usr/bin/env bash
# Starting state for the segmentation lab. Environment only: it creates the
# workloads. It creates no NetworkPolicy, ResourceQuota or LimitRange.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n depot rollout status deployment/ledger --timeout=180s
kubectl -n depot rollout status deployment/loader --timeout=180s
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
echo "[lab] Ready."
