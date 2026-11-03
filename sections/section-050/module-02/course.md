# Controlling Which Images Run

A team can agree that only approved images run in the cluster, and the agreement still depends on people. The cluster can enforce the rule itself: the API server checks every new pod before it stores it. This module shows how to write that check with a `ValidatingAdmissionPolicy`, how to roll it out without breaking running workloads, and where signature and scan controls fit around it. It teaches what the KCSA exam calls controlling the sources and the identity of the artifacts that run.

## Learning objectives

After this module you can:

- Explain where admission sits after authorization and why RBAC cannot check an image.
- Write a `ValidatingAdmissionPolicy` and a `ValidatingAdmissionPolicyBinding` that allow only approved registries, with init containers and a scoped namespace.
- Explain why a prefix needs a trailing slash and why a Deployment is accepted while its pods are rejected.
- Require images by digest and roll the rule out with `Warn` and `Audit` before `Deny`.
- Explain what a signature, an attestation and a scan prove, and where each one is verified.
- Explain why a built-in policy cannot verify a signature, and what `failurePolicy` does when a webhook is down.

## Before you start

You need Kubernetes basics: namespaces, pods, Deployments and the commands `kubectl apply`, `kubectl get` and `kubectl patch`. You need to know what an image reference with a tag and with a digest looks like. No extra tool is needed.

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with no admission policy installed. It has these objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application |
| `outpost` | `drifter` | A client that belongs to another team |
| `dockyard` | Deployments `relay`, `hauler`, `stray` | Images from three different registries, all scaled to zero replicas |
| `dockyard` | ConfigMap `release-record` | A recorded digest |

## Reading order

1. Approved Registries At Admission: the admission step, a policy and a binding, and a Deployment whose pods fail.
2. Requiring Digests And Rolling Out A Policy: the digest rule, the actions `Warn`, `Audit` and `Deny`, and scope.
3. Verifying Signatures And Scanning In The Pipeline: signatures, attestations, scans and what they prove.
4. Summary

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
