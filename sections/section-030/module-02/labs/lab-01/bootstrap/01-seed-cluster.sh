#!/usr/bin/env bash
# Starting state for the admission policy lab. Environment only: the Starfleet
# workloads (probe without a memory limit), a policy that checks the wrong
# field, and a binding that only warns and selects no namespace. The learner
# fixes it.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/policy-start.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
