---
draft: true
exam_objectives:
  - Workload and Application Code Security
---
# Application Code And Workload Protection

A cluster can run only hardened pods and still leak data, because the code inside the pod decides what each caller may read. This module shows where the application code ends and the platform begins. It covers three questions: what the application must check itself, how a workload receives a credential without exposing it, and how a team knows what code and dependencies run in a pod.

## Learning objectives

After this module you can:

- Explain why input validation, authorization and injection defence are tasks of the application code and not of Kubernetes.
- Show with a running pod that the platform passes untrusted input and unauthenticated requests through unchanged.
- Move a credential out of an image, an environment literal and a pod template into a Secret, and choose between an environment variable and a Secret volume.
- Explain why a Secret is encoded and not encrypted, and which settings limit who can read it.
- Name the main kinds of application testing (static analysis, dynamic analysis, software composition analysis, fuzzing) and say what evidence each one produces.
- Read the image reference and image digest of a running pod and find containers that are not pinned.

## What to know first

You need Kubernetes basics: pods, Deployments, namespaces, Services, and the commands `kubectl get`, `kubectl apply`, `kubectl describe` and `kubectl exec`. You need no programming skill and no scanner. Every term is explained where it first appears.

## The order of the parts

The first part covers untrusted input, authorization and injection, and shows what the platform does and does not check. The second part covers Secrets: how a credential reaches a process, what a Secret protects and what it does not. The third part covers testing and dependencies: the kinds of analysis a team runs on its code, and how to read exactly which image a pod runs.

## The playground

Your playground is a single-node `kind` cluster running Kubernetes 1.35 with no extra tools. The `kubectl` command points at it as the cluster administrator.

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The example workloads `scout` (a podinfo web service), `probe` (a go-httpbin service that echoes what it receives) and `shuttle` (a curl client). A Secret `scout-db`, a Deployment `legacy-report` that has a password written into its pod template, and a Role that lets `shuttle` read Secrets |
| `outpost` | The `drifter` curl client, outside the application namespace |

Launch your playground now and keep it running while you read the parts:

<!-- astrona:playground -->
