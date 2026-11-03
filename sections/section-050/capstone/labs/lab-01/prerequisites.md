# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl` and `jq`.
- You know digest pinning, image pull secrets on a service account, and admission policies written in the Common Expression Language (CEL).

The lab starts a single-node kind cluster (Kubernetes 1.35). It needs no extra tool and no internet access to a registry, because no pod in this lab has to start. The commands for the lab are in the README of this folder.
