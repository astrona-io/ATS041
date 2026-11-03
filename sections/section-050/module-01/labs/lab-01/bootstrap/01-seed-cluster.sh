#!/usr/bin/env bash
# Starting state for this lab. Environment only: it creates the namespaces,
# service accounts and Deployments. It does not create any object that the
# learner must write. The faults are left in place on purpose.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
echo "[lab] Ready."
