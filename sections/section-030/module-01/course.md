---
draft: true
exam_objectives:
  - Controls and Frameworks
---
# Controls, Risk And Frameworks

A security rule that nobody enforces protects nothing. This module teaches the words the KCSA (Kubernetes and Cloud Native Security Associate) exam uses to talk about security controls: threat, vulnerability, risk, control, framework, benchmark, evidence and residual risk. It also shows the difference between a preventive, a detective and a corrective control on a real cluster.

Keep one sentence in mind for this module: **a control is only as good as the evidence that it works.** You will make one Kubernetes feature act as a preventive and as a detective control, collect evidence from the API with `kubectl` and `jq`, and record an accepted risk in a namespace of its own.

## Learning objectives

After this module you can:

- Distinguish a threat, a vulnerability, a risk and a security control.
- Compare preventive, detective and corrective controls, and give a Kubernetes example of each.
- Explain how a framework (NIST CSF, PCI DSS, NIST SSDF, SLSA) differs from a benchmark (CIS Kubernetes Benchmark).
- Collect evidence about the live cluster state with `kubectl` and `jq`.
- Name the six STRIDE threat categories and match each one to a control.
- Choose a risk treatment (mitigate, avoid, transfer, accept) and describe the residual risk.

## Before you start

You need Kubernetes basics: namespaces, pods, Deployments, labels, and the commands `kubectl get`, `kubectl apply` and `kubectl label`. You do not need any extra tool. Pod Security Admission is built into Kubernetes.

## The order of the parts

The module has three parts. **From A Security Goal To A Verifiable Control** defines the vocabulary and shows one control working as a preventive and as a detective control. **Frameworks, Benchmarks And Evidence** explains what frameworks and benchmarks are for and collects evidence from the API. **Threat Modeling And Residual Risk** covers STRIDE, the four risk treatments and a contained, documented exception.

## Your playground

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with no extra tools:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | No Pod Security labels. The example workloads `scout`, `probe` and `shuttle` run here. A `debug-tools` Deployment runs a privileged container, on purpose |
| `outpost` | The `drifter` client runs here |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
