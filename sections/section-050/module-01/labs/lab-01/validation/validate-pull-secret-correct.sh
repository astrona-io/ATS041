#!/usr/bin/env bash
# Check: registry-creds is a kubernetes.io/dockerconfigjson Secret for
# registry.starfleet.example with the right user name and password. The
# password is compared but never printed.
set -uo pipefail

type="$(kubectl -n dockyard get secret registry-creds -o jsonpath='{.type}' 2>/dev/null || true)"
if [ "$type" != "kubernetes.io/dockerconfigjson" ]; then
  echo "FAIL: secret registry-creds in dockyard must have type kubernetes.io/dockerconfigjson (found '${type}')"
  exit 1
fi

config="$(kubectl -n dockyard get secret registry-creds -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d 2>/dev/null || true)"
user="$(echo "$config" | jq -r '.auths["registry.starfleet.example"].username // empty' 2>/dev/null || true)"
pass="$(echo "$config" | jq -r '.auths["registry.starfleet.example"].password // empty' 2>/dev/null || true)"

if [ "$user" != "fleet-puller" ]; then
  echo "FAIL: the secret has no entry for registry.starfleet.example with user fleet-puller"
  exit 1
fi
if [ "$pass" != "d0ck-pull-7731" ]; then
  echo "FAIL: the password in the secret is not the one given in the task"
  exit 1
fi
echo "PASS: registry-creds is a dockerconfigjson Secret for registry.starfleet.example"
