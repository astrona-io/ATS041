#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet patch deployment probe -p '{
  "spec": {"template": {"spec": {
    "securityContext": {
      "runAsNonRoot": true,
      "runAsUser": 65532,
      "seccompProfile": {"type": "RuntimeDefault"}
    },
    "containers": [{
      "name": "probe",
      "securityContext": {
        "allowPrivilegeEscalation": false,
        "readOnlyRootFilesystem": true,
        "capabilities": {"drop": ["ALL"]}
      }
    }]
  }}}
}'
kubectl -n starfleet rollout status deployment/probe --timeout=180s

kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
