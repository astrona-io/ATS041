---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Segmentation Across Workloads And Identities

A compromised `scout` process should not automatically reach every other application or administer its node. Segmentation divides access into defined boundaries. A useful design combines process isolation, network paths, identities and resource policy according to the actual trust relationships.

## Namespaces Are Only One Scope

A Kubernetes namespace scopes many object names, permissions and policies. It does not create a separate kernel, dedicated node or automatic network denial. Two namespaces can share workers and communicate by default under the ordinary NetworkPolicy model. Strong multi-tenant separation needs more than distinct names.

Namespace-scoped role-based access control (RBAC) can narrow application programming interface (API) actions, while quotas constrain aggregate resource requests or object counts. NetworkPolicy can restrict supported traffic directions when implemented by the network system. Pod security settings constrain declared process privileges. These are separate controls with different components and failure behavior.

## Shared Nodes And Stronger Boundaries

Several Pods on one worker commonly share its kernel. A kernel or runtime vulnerability can therefore have wider consequences than an application-local defect. Restrict privileges and host mounts, maintain the host and evaluate a stronger sandbox or dedicated infrastructure when workload trust requires it.

A dedicated node group reduces some co-location exposure but still belongs to a cluster whose control plane and administrators can manage it. A separate cluster adds an API and operating boundary but may share infrastructure accounts or external data services. A virtual-machine boundary adds a separate guest kernel while still relying on its host and management plane.

State the exact boundary instead of labeling a design “isolated.” Which identity may cross it? Which administrative role can reconfigure it? Which network paths remain? Which shared kernel or data service can couple the workloads? These questions reveal where a claimed boundary depends on another trusted component.

## Containment After Compromise

Suppose an untrusted application receives no API token, has restricted runtime privileges and can reach only its required data endpoint. If its code is compromised, those controls reduce available routes and authority. They do not prevent abuse of the data endpoint through permissions legitimately granted to the application. Data-specific authorization and monitoring remain necessary.

Resource limits can constrain some central processing unit (CPU) or memory consumption, while quotas control admitted aggregate requests. They do not protect every shared dependency from expensive requests. A database or gateway can need its own rate and concurrency controls. Containment should follow the workload's full request path.

## Choosing A Boundary From Risk

An internal service with a narrow trust relationship may operate safely with shared nodes and strong policy. Mutually untrusted customer code can require stronger isolation, dedicated resources or separate management boundaries. The choice should consider the consequence of a shared-component failure, not only normal-path permission checks.

A complete containment design identifies what a compromised process can read, change, connect to and consume. It also identifies which operators can alter those boundaries and how misuse is detected. This is more meaningful than relying on the existence of one namespace or one security-context field.

## Common pitfalls

> [!WARNING]
> Separate namespaces do not automatically isolate network traffic or kernels. Dedicated nodes and separate clusters also depend on their shared management and infrastructure trust.
