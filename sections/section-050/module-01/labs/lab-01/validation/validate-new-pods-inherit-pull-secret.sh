#!/usr/bin/env bash
# Check: a new pod that uses the hauler ServiceAccount receives registry-creds
# from admission (server-side dry run), and the hauler Deployment does not set
# imagePullSecrets itself.
set -uo pipefail
fail=0

pod="$(kubectl create --dry-run=server -o json -f - 2>/dev/null <<MANIFEST
apiVersion: v1
kind: Pod
metadata:
  name: grader-probe
  namespace: dockyard
spec:
  serviceAccountName: hauler
  containers:
  - name: main
    image: registry.starfleet.example/fleet/hauler:2.4
MANIFEST
)"
inherited="$(echo "$pod" | jq -r '[.spec.imagePullSecrets[]?.name] | index("registry-creds") // empty' 2>/dev/null || true)"
if [ -z "$inherited" ]; then
  echo "FAIL: a new pod on the hauler ServiceAccount does not receive registry-creds"
  fail=1
fi

own="$(kubectl -n dockyard get deployment hauler -o json 2>/dev/null | jq -r '.spec.template.spec.imagePullSecrets // [] | length')"
if [ "$own" != "0" ]; then
  echo "FAIL: the hauler Deployment must not set imagePullSecrets itself; use the ServiceAccount"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: new pods inherit registry-creds from the ServiceAccount"
fi
exit "$fail"
