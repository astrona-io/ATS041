#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail


kubectl label namespace outpost \
  pod-security.kubernetes.io/enforce=baseline \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted --overwrite
kubectl -n outpost delete pod intruder
kubectl -n starfleet rollout undo deployment/probe
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[solution] Applied."
