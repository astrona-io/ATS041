---
draft: true
exam_objectives:
  - Controls and Frameworks
---
# Enforcing Controls With Admission Policy

A framework or a policy document says what a cluster must do, and the cluster still accepts whatever it is sent. This module shows how a team turns a written rule into a control that the Kubernetes API server enforces on every request. It uses the built-in ValidatingAdmissionPolicy, tests the control from both sides and states what the control does not cover.

Keep one sentence in mind for this module: **a policy object plus a binding gives the API server a rule, a scope and an effect.** You will write one rule in CEL, bind it to one namespace, move it from warning to blocking, and find a request that the rule does not see.

## Learning objectives

After this module you can:

- Describe where admission runs in the path of an API request and how it differs from authorization.
- Write a ValidatingAdmissionPolicy with a CEL expression and a ValidatingAdmissionPolicyBinding that scopes it to a namespace.
- Choose between the `Deny`, `Warn` and `Audit` validation actions and describe a safe rollout.
- Test a control with one request that must be rejected and one that must be accepted.
- Name a request that a given policy does not match, and state the residual risk.

## Before you start

You need Kubernetes basics: namespaces, Deployments, labels, and the commands `kubectl get`, `kubectl apply` and `kubectl patch`. You do not need to know CEL. The examples explain the few expressions they use. No extra tool is needed, because the feature is built into Kubernetes 1.35.

## The order of the parts

The module has three parts. **From A Written Policy To An Admission Check** explains admission and builds a policy and a binding. **Warn, Audit And Deny: Rolling Out A Control** explains the validation actions and a rollout in steps. **Evidence, Gaps And Residual Risk** tests the control from both sides, shows a bypass and writes down what remains.

## Your playground

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with no extra tools:

| Namespace | What is in it |
| --- | --- |
| `starfleet` | The example workloads `scout`, `probe` and `shuttle`. `probe` has no memory limit, on purpose. No policy exists yet |
| `outpost` | The `drifter` client runs here |

`kubectl` already points at the playground cluster, as the cluster administrator.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
