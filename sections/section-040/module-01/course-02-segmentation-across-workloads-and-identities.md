---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Segmentation Across Workloads And Identities

Teams often say "our workloads are isolated, they are in different namespaces". Then a compromised pod in one namespace sends a request to a database in another namespace, and the request succeeds. The word "namespace" made the team believe in a boundary that does not exist by default. This part explains what a Kubernetes namespace separates, what it leaves open, and which other controls divide a cluster into real segments.

## What a Kubernetes namespace does

A Kubernetes namespace is a scope for the names of API objects. Two namespaces can each hold a Service called `probe`, and the two objects do not clash. The namespace is also the scope that other controls attach to: a `Role` grants rights in one namespace, a `ResourceQuota` limits the use of one namespace, and a `NetworkPolicy` selects pods in one namespace.

The namespace itself does not do any of those jobs. It does not block network traffic. It does not place pods on different nodes. It does not give pods a different kernel. A namespace with no `NetworkPolicy`, no `Role` rules and no quota is only a label on the objects.

The exam names the idea of **segmentation**: dividing a system into parts so that a failure or an attacker in one part cannot freely reach the others. A segment can be drawn in several layers, and each layer needs its own control:

| Layer | What separates the segments | Control in Kubernetes |
| --- | --- | --- |
| API access | Who may read or change objects | RBAC (role-based access control) per namespace |
| Network | Which pods may send packets to which pods | NetworkPolicy, enforced by the network plugin |
| Resources | How much CPU and memory a segment may take | ResourceQuota and LimitRange |
| Identity | Which credentials a pod holds | Service accounts, token mounting |
| Kernel and node | Which workloads share a kernel | Dedicated nodes, sandboxed runtimes, separate clusters |

Each row is a separate control with a separate failure mode. Setting up one row does not fill the others.

## Prove that a namespace does not block traffic

The playground has `drifter` in the namespace `outpost` and the `probe` Service in the namespace `starfleet`. Call `probe` from `drifter` with its full DNS name. A Service gets a name of the form `<service>.<namespace>.svc.cluster.local`, which the cluster DNS resolves for pods in every namespace.

<!-- astrona:playground:renew -->

```sh
kubectl exec deploy/drifter -n outpost -- curl -s -o /dev/null -w '%{http_code}\n' http://probe.starfleet.svc.cluster.local/status/200
```

The command prints `200`. The request crossed from one namespace to another without any rule stopping it, because no `NetworkPolicy` exists. By default, a pod in a Kubernetes cluster accepts traffic from every other pod, in every namespace. A cluster is a flat network until a `NetworkPolicy` and a network plugin that enforces it change that.

## Identities are a second segment

A pod also holds an identity. The pod runs as a **service account**, which is the identity a pod uses when it calls the Kubernetes API. By default, the kubelet mounts a token for that service account into every container, in the directory `/var/run/secrets/kubernetes.io/serviceaccount`. The token is a signed credential that the API server accepts. List the directory in `shuttle`:

```sh
kubectl exec deploy/shuttle -n starfleet -- ls /var/run/secrets/kubernetes.io/serviceaccount
```

The command lists three files: `ca.crt`, `namespace` and `token`. The `shuttle` application only calls other pods with `curl`. It never calls the Kubernetes API, so it does not need the token. If an attacker takes over the container, the attacker can read the token and send API requests as that service account. The rights of the service account then become the rights of the attacker.

Two controls reduce this risk. First, give each workload its own service account and grant only the rights it needs. A pod that uses a shared account with wide rights hands those rights to everyone who compromises it. Second, set `automountServiceAccountToken: false` on the pod or on the service account, so that no token is mounted when the workload does not call the API. The field on the pod takes precedence over the field on the service account.

You can see the service accounts of the example workloads:

```sh
kubectl get serviceaccounts -n starfleet
```

Each workload has its own account, and none uses the `default` service account. That is the first step. The second step, turning off the token mount, is a field in the pod spec.

## Shared nodes and stronger boundaries

Two pods in different namespaces can still run on the same node. They then share the node kernel, the container runtime and the kubelet. A kernel flaw reaches both. For workloads that do not trust each other, a namespace is therefore too weak a boundary on its own.

The stronger boundaries cost more and are chosen by risk:

- **Dedicated nodes.** Labels, taints and tolerations keep a team's pods on its own nodes, so that no other team's pod shares their kernel. The control plane and the cluster administrators still manage those nodes.
- **Sandboxed runtimes.** A pod selects a `RuntimeClass` whose runtime gives the pod its own kernel layer or lightweight virtual machine.
- **Separate clusters.** Each tenant gets its own API server and nodes. This is the strongest split inside one organization, and it costs the most to run.

The word **tenant** means one team or customer that shares the cluster with others. Multi-tenancy is the practice of hosting several tenants on one cluster, and every row of the table above is part of a multi-tenant design.

## Choose the boundary from the trust relationship

The right boundary depends on how much the workloads trust each other and on what a failure would cost. Two examples show the difference.

An internal API and its batch job belong to one team and run code the team reviewed. Shared nodes, one namespace each, least-privilege RBAC and a `NetworkPolicy` are a reasonable design. A failure in one of them is a failure of the same team.

A platform that runs code uploaded by customers is a different case. The code is untrusted by definition, so a kernel flaw is part of the threat model. A design for it uses sandboxed runtimes or dedicated nodes for each customer, and may use separate clusters for the most sensitive customers. Packaging both workloads as container images does not make them equal. The image format says nothing about trust.

Name the exact boundary in a design instead of calling the design "isolated". Ask which identity can cross it, which administrator can reconfigure it, which network paths stay open and which shared kernel or data service still links the workloads.

## Containment after a compromise

Plan the segments by asking what a compromised pod can do. It can read the files and environment of its own container. It can use the token it holds. It can send packets to every pod that the network allows. It can consume the CPU and memory its limits permit. It can try to escape to the node if the pod spec grants host access.

Each control closes one of those routes. RBAC and token settings limit the API route. NetworkPolicy limits the network route. Quota and limits limit the resource route. The pod security fields limit the node route. None of the controls helps against abuse of what the pod is allowed to do. If `scout` may read a database, an attacker who takes over `scout` may read it too. Least privilege and monitoring remain necessary.

You now know that a namespace is a scope, not a wall, and that identity, network and resources are separate segments. What is still open is the part of the pod spec that connects a container to the node itself.

## Common pitfalls

> [!WARNING]
> A Kubernetes namespace does not isolate network traffic, kernels or nodes. A `NetworkPolicy` object has no effect when the network plugin does not enforce it. Service account tokens are mounted by default, even for pods that never call the API. A dedicated node group or a separate cluster still depends on the administrators and the infrastructure that manage it.
