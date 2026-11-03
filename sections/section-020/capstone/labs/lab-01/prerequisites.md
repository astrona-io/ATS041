# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know how to switch off a service account token mount, how to replace a cluster-wide binding with a Role, how an `ipBlock` with `except` is written in a NetworkPolicy, what the group `system:unauthenticated` is, and what the Pod Security `baseline` level forbids.

The lab starts a single-node kind cluster (Kubernetes 1.35) with one namespace. The commands for the lab are in the README of this folder.
