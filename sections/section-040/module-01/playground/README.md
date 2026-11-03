# Isolation And Containment Boundaries — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-041-playground-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in
`outpost`), a `crew-share` Deployment whose two containers share one process
namespace, and a `relay` Deployment in `outpost` that runs with `hostPID`.
Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-01/playground
astrona destroy ats-041-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name` =
`ats-041-playground-040-01`), not the config path. `astrona submit` and
`astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/isolation.yaml` | `crew-share` (shared process namespace) and `relay` (hostPID) |
| `docs/overview.md` | What the environment contains and ideas to try |
