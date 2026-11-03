#!/usr/bin/env bash
# Starting state for the controls lab. Environment only: it creates the
# workloads, an unmanaged privileged pod and a failed probe rollout. It does
# not create any label or control the learner must add.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s

kubectl apply -f "$DIR/manifests/intruder.yaml"
kubectl -n outpost wait --for=condition=Ready pod/intruder --timeout=180s

# A bad rollout: the new image tag does not exist. The old pod keeps serving.
kubectl -n starfleet set image deployment/probe probe=mccutchen/go-httpbin:does-not-exist-0
echo "[lab] Ready."
