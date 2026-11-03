# Question

Solve this question on: `terminal`

The dockyard team prepares a release. The namespace `dockyard` already exists. Its two Deployments, `relay` and `hauler`, are scaled to zero replicas on purpose, so their images are never pulled. Fix three problems. Do not scale the Deployments and do not change the image of `hauler`.

1. The Deployment `relay` runs the container `relay` with the image `ghcr.io/stefanprodan/podinfo:latest`. The release process recorded the approved digest in the key `relay-digest` of the ConfigMap `release-record` in `dockyard`. Change the image to the same repository, referenced by that digest, with no tag.

2. Pods in `dockyard` pull from the private registry `registry.starfleet.example`. Create the Secret `registry-creds` in `dockyard` so that it holds the registry credentials. It must have the type `kubernetes.io/dockerconfigjson`, the server `registry.starfleet.example`, the user name `fleet-puller` and the password `d0ck-pull-7731`.

3. Every pod that runs as the service account `hauler` must receive `registry-creds` as an image pull secret. Do it on the service account, not on the Deployment: the Deployment `hauler` must not list `imagePullSecrets` in its pod template.

`kubectl` already points at the cluster as the cluster administrator.
