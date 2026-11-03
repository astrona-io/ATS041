# Question

Solve this question on: `terminal`

The Starfleet logistics team found that the `ledger` Deployment in `starfleet` keeps its database password as a literal value in the pod template, and that the `shuttle` service account can read every Secret in the namespace. Fix both with `kubectl`. Do not change `scout`, `probe` or `drifter`, and do not delete any service account.

1. Read the current value of the `DB_PASSWORD` variable in the `ledger` pod template. Create a Secret named `ledger-db` in `starfleet` with the key `password` and that same value.

2. Change the `ledger` Deployment so that it has no literal password anywhere in its pod template. It must receive the Secret as a volume called `db-credentials` that is mounted read only at `/etc/ledger-db` in the `ledger` container. Remove the `DB_PASSWORD` variable.

3. Remove the permission that lets the `shuttle` service account read Secrets. After your change, `shuttle` must not be able to `get`, `list` or `watch` Secrets in `starfleet`, and the service account must still exist.

4. After your changes, the `ledger` Deployment must be rolled out and ready.

`kubectl` already points at the cluster as the cluster administrator. You can check any identity with `--as`.
