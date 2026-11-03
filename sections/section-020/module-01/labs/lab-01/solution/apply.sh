#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for workload in scout probe; do
  kubectl -n starfleet patch deployment "$workload" -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
done
for workload in scout probe; do
  kubectl -n starfleet rollout status "deployment/${workload}" --timeout=180s
done

kubectl apply -f "$DIR/solution.yaml"
kubectl delete clusterrolebinding build-runner-admin
echo "[solution] Applied."
