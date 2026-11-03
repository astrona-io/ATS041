# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know what a `NetworkPolicy`, a `ResourceQuota` and a `LimitRange` are, and how the AND and OR rules of policy peers work.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the namespaces `depot` and `starfleet`. The commands for the lab are in the README of this folder.
