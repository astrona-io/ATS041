---
draft: true
exam_objectives:
  - Artifact Repository and Image Security
---
# Artifact And Image Assurance

Every container in a cluster starts from an image that someone built, stored in a registry and pulled by a node. Each step can go wrong: the credentials can leak, a tag can point to different content than yesterday, and the image can contain a secret or a vulnerable library. The KCSA exam asks which control fits which step. This module teaches the mechanisms behind those answers and lets you see them work.

## Learning objectives

After this module you can:

- Create a `kubernetes.io/dockerconfigjson` Secret with `kubectl create secret docker-registry` and explain why it is readable by anyone who can get Secrets.
- Deliver a pull secret through a service account and prove with a server-side dry run that a new pod receives it.
- Distinguish a digest, a signature, provenance, a software bill of materials (SBOM) and a vulnerability scan, and say what each proves.
- Explain why a tag is not an identity, pin a Deployment to a digest, and read the `imageID` that a pod really ran.
- State how `imagePullPolicy` is defaulted and when it is set.
- Explain what enters image layers, why deleting a file in a later layer does not remove it, and how multi-stage builds and small bases help.

## Before you start

You need Kubernetes basics: namespaces, Deployments, pods, Secrets and the commands `kubectl get`, `kubectl apply` and `kubectl patch`. A text-only description of containers is enough; no image building is needed.

Your playground is a single-node `kind` cluster running Kubernetes 1.35 with no extra tools. It has the following objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application |
| `outpost` | `drifter` | A client that belongs to another team |
| `dockyard` | Deployment `relay` | Uses `ghcr.io/stefanprodan/podinfo:latest`, scaled to zero replicas |
| `dockyard` | Deployment and service account `hauler` | Uses an image from the private registry `registry.starfleet.example`, scaled to zero replicas, no pull secret |
| `dockyard` | ConfigMap `release-record` | The digest approved for `relay`, in the key `relay-digest` |

## Reading order

1. Credentials And Image Verification Evidence: pull secrets, service accounts and what a registry can prove.
2. Repository Policy And The Deployed Artifact: tags, digests, pull policy and the `imageID` of a running pod.
3. Build Inputs And Image Contents: layers, build secrets, multi-stage builds and base images.
4. Summary

Launch your playground now and keep it running while you read:

<!-- astrona:playground -->
