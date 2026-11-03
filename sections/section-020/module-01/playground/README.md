# Cloud And Infrastructure Responsibilities - Playground

- **Slug:** ats-041-playground-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`). the Starfleet workloads in starfleet and outpost, and a build-runner service account bound to cluster-admin (on purpose). Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/playground
astrona destroy ats-041-playground-020-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/access.yaml` | The objects that the module examines |
| `docs/overview.md` | What the environment contains and ideas to try |
