# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know the four layers, Pod Security Admission labels and the restricted settings, service account tokens, and how to roll back a Deployment.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the namespace `relay`. The commands for the lab are in the README of this folder.
