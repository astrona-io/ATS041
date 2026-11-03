#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
# The probe patch comes first: with the corrected policy in Deny mode it is
# accepted because it adds the limit.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"containers":[{"name":"probe","resources":{"limits":{"memory":"64Mi"}}}]}}}}'
kubectl -n starfleet rollout status deployment/probe --timeout=180s

kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
