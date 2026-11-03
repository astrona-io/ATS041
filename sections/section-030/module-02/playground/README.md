# Enforcing Controls With Admission Policy — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-041-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`). The
Starfleet workloads run in `starfleet`; `probe` has no memory limit (on
purpose). No admission policy exists yet. Nothing to submit.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/playground
astrona destroy ats-041-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name` =
`ats-041-playground-030-02`), not the config path. `astrona submit` and
`astrona test` do not apply — there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts, workloads (`probe` without a memory limit) |
| `docs/overview.md` | What the environment contains and ideas to try |
