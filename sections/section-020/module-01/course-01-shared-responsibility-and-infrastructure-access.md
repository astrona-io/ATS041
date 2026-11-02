---
draft: true
exam_objectives:
  - Cloud Provider and Infrastructure Security
---
# Shared Responsibility And Infrastructure Access

A team uses a managed Kubernetes service for `scout`. The provider maintains part of the platform, but the customer still chooses workload identities, images, data exposure and application permissions. Shared responsibility means each party has defined duties; it does not mean all security transfers to the provider.

## Identifying Who Owns A Control

For a self-managed cluster, the operator may own host patching, certificates, datastore backups, control plane exposure and node replacement. A managed control plane transfers some of that work. A more managed node offering can transfer more. The service agreement determines the actual allocation, so the phrase “managed Kubernetes” is not a complete responsibility matrix.

Map each protection to an owner. Who configures the application programming interface (API) endpoint's network access? Who patches worker images? Who encrypts and backs up application volumes? Who decides which identities can change workloads? A missing answer is an operating gap even if the underlying service has strong provider controls.

Physical isolation and hypervisor protection can belong to the provider, while customer account configuration remains local. A compromised customer administrator can misuse legitimate management APIs without exploiting the provider's physical infrastructure. Strong provider security therefore does not replace scoped customer permissions.

## Infrastructure Identities And Blast Radius

An infrastructure identity may create machines, attach disks, change firewalls or inspect managed service settings. Blast radius is the set of assets affected when that authority is misused. A narrowly scoped application identity has a different radius from an account administrator controlling the whole environment.

Prefer distinct identities for deployment, routine operation and emergency administration. Use strong authentication and avoid widely shared permanent credentials. Automated jobs should receive only the capabilities they need, with limited lifetime when supported. Observe changes to sensitive access rules and credentials.

Instance metadata services can expose information and workload credentials to applications through local infrastructure interfaces. Access and protection depend on the platform. An application vulnerability that reaches metadata can become a credential exposure if the surrounding configuration permits it. Restrict the path and the resulting identity privileges rather than assuming an internal address is harmless.

## Network And Storage Boundaries

A firewall can restrict which sources reach the API endpoint, but an allowed connection still needs authenticated and authorized requests. Conversely, a valid credential does not make an unreachable private endpoint accessible from every location. Network and identity controls protect different parts of the path.

Storage encryption protects defined at-rest boundaries. A process or administrator with authorized read access can still receive plaintext. Encryption keys need access controls, rotation and recovery plans, and backups can have their own exposure paths. Saying that a volume is encrypted does not establish that every reader is legitimate.

## A Managed-Cluster Scenario

Suppose the provider keeps API servers patched, but the customer grants a build job permission to administer every cluster. A malicious build input can use that legitimate credential to alter workloads. The provider's patching duty was fulfilled; the customer identity boundary was still too broad.

A suitable correction narrows the job's role, separates build and production identities, revokes exposed credentials and checks affected resources. Infrastructure logs and cluster audit evidence help establish what the identity changed. Application data may require independent recovery if the misuse reached a database or volume.

A good infrastructure explanation connects contract, identity, network path and data lifecycle. These details make shared responsibility actionable: each important control has an owner, a defined scope and evidence for both normal operation and incident recovery.

## Common pitfalls

> [!WARNING]
> Managed infrastructure does not eliminate customer identity and data responsibilities. At-rest encryption and private addressing do not automatically authorize every reader or caller.
