# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know what a service account token is, what `automountServiceAccountToken` does, what a Role and a RoleBinding do, and how an `ipBlock` with `except` is written in a NetworkPolicy.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads. The commands for the lab are in the README of this folder.
