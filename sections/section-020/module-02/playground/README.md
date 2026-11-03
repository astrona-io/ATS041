# Control Plane, Node And Data Boundaries - Playground

- **Slug:** ats-041-playground-020-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground - clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`). the Starfleet workloads, a binding that gives the view role to unauthenticated callers, a node-inspector Deployment with a hostPath mount, a Secret and a ConfigMap, and a Role that lets scout read Secrets (all on purpose). Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-02/playground
astrona destroy ats-041-playground-020-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/exposure.yaml` | The objects that the module examines |
| `docs/overview.md` | What the environment contains and ideas to try |
