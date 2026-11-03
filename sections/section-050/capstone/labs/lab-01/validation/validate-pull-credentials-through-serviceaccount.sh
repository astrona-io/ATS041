#!/usr/bin/env bash
# Check: registry-creds is a dockerconfigjson Secret for the right registry,
# the loader ServiceAccount lists it, new pods inherit it, and no Deployment
# sets imagePullSecrets itself. The password is compared but never printed.
set -uo pipefail
fail=0

type="$(kubectl -n shipyard get secret registry-creds -o jsonpath='{.type}' 2>/dev/null || true)"
if [ "$type" != "kubernetes.io/dockerconfigjson" ]; then
  echo "FAIL: secret registry-creds in shipyard must have type kubernetes.io/dockerconfigjson (found '${type}')"
  exit 1
fi
config="$(kubectl -n shipyard get secret registry-creds -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d 2>/dev/null || true)"
user="$(echo "$config" | jq -r '.auths["registry.starfleet.example"].username // empty' 2>/dev/null || true)"
pass="$(echo "$config" | jq -r '.auths["registry.starfleet.example"].password // empty' 2>/dev/null || true)"
if [ "$user" != "cargo-puller" ] || [ "$pass" != "s3al-pull-4410" ]; then
  echo "FAIL: the secret does not hold the registry.starfleet.example user and password from the task"
  fail=1
fi

listed="$(kubectl -n shipyard get serviceaccount loader -o json 2>/dev/null | jq -r '[.imagePullSecrets[]?.name] | index("registry-creds") // empty')"
if [ -z "$listed" ]; then
  echo "FAIL: the loader ServiceAccount does not list registry-creds in imagePullSecrets"
  fail=1
fi

pod="$(kubectl create --dry-run=server -o json -f - 2>/dev/null <<MANIFEST
apiVersion: v1
kind: Pod
metadata:
  name: grader-probe
  namespace: shipyard
spec:
  serviceAccountName: loader
  containers:
  - name: main
    image: registry.starfleet.example/fleet/tug@sha256:0000000000000000000000000000000000000000000000000000000000000000
MANIFEST
)"
inherited="$(echo "$pod" | jq -r '[.spec.imagePullSecrets[]?.name] | index("registry-creds") // empty' 2>/dev/null || true)"
if [ -z "$inherited" ]; then
  echo "FAIL: a new pod on the loader ServiceAccount does not receive registry-creds"
  fail=1
fi

own="$(kubectl -n shipyard get deployments -o json 2>/dev/null | jq -r '[.items[] | select((.spec.template.spec.imagePullSecrets // []) | length > 0)] | length')"
if [ "$own" != "0" ]; then
  echo "FAIL: no Deployment may set imagePullSecrets itself; use the ServiceAccount"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: pull credentials are correct and used through the ServiceAccount"
fi
exit "$fail"
