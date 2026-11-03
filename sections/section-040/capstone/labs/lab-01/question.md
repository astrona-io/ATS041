# Question

Solve this question on: `terminal`

A new team moves into the namespace `annex`. It runs two workloads: the backend `scribe` (container port 8080, behind the Service `scribe` on port 80) and the client `courier`, which only sends HTTP requests to `scribe`. The review of the namespace found three problems. The `courier` pods share the network and process namespaces of the node, run a privileged container and mount a directory of the node. The namespace has no network segmentation. The namespace has no limits on resource use.

1. Remove the host access from `courier`. Its pods must not use `hostNetwork`, `hostPID` or `hostIPC`, must not be privileged, must not mount any `hostPath` volume, must not gain privileges, must drop all capabilities and add none, and must not receive a service account token.

2. Deny all ingress traffic in `annex` by default, then allow `scribe` to accept traffic only from the `courier` pods in the same namespace, only on TCP port 8080.

3. Restrict the egress traffic of `courier`. It may send traffic only to the `scribe` pods on TCP port 8080 and to DNS (port 53, UDP and TCP) in the `kube-system` namespace.

4. Add a ResourceQuota to `annex` with at most 6 pods and limits on `requests.memory` and `limits.memory`. Add a LimitRange of type Container that sets a default memory request and a default memory limit.

Keep the Deployment names, the pod labels `app=scribe` and `app=courier` and the container images. Both Deployments must be rolled out when you finish. Do not change other namespaces. `kubectl` already points at the cluster as the cluster administrator.
