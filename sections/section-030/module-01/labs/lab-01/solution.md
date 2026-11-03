# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01
```

## Step 1: Find what baseline would reject

A server-side dry run of the label shows which pods break the level, without changing anything:

```sh
kubectl label --dry-run=server --overwrite namespace starfleet pod-security.kubernetes.io/enforce=baseline
```

The command prints a warning that names the pod of `debug-tools`, because a privileged container breaks `baseline`. The pods of `scout`, `probe` and `shuttle` are not named, because they pass `baseline`. The namespace is not changed. Enforcing the level on the namespace does not remove a running pod, so the pod needs a separate corrective step later.

## Step 2: Add the preventive and detective labels

The three labels together make one control with two purposes: `enforce` blocks, and `warn` and `audit` report at the stricter level. Save this as `namespace-starfleet-controls.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: starfleet
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
```

Apply it:

```sh
kubectl apply -f namespace-starfleet-controls.yaml
```

Then check the result:

```sh
kubectl get namespace starfleet --show-labels
```

The labels appear in the list. Submit and see which checks pass:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01 --keep
```

The checks for the two label tasks pass. The check for the privileged pod still fails, because `debug-tools` runs.

## Step 3: Delete debug-tools

Delete the Deployment, not only its pod. The Deployment controller would create a new pod for a deleted pod, and the new pod would be rejected by the `enforce` label.

```sh
kubectl -n starfleet delete deployment debug-tools
```

The output is `deployment.apps "debug-tools" deleted from starfleet namespace`. Check that nothing privileged is left:

```sh
kubectl get pods -A -o json | jq -r '.items[] | select(any(.spec.containers[]; .securityContext.privileged == true)) | "\(.metadata.namespace)/\(.metadata.name)"'
```

The pods in `kube-system` can appear in this list on a kind cluster, which is normal. No pod of `starfleet` may appear. Submit again:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01 --keep
```

## Step 4: Stop shuttle from mounting the token

The setting `automountServiceAccountToken: false` goes into the pod template, so that new pods start without the token. A strategic merge patch changes only that field:

```sh
kubectl -n starfleet patch deployment shuttle -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n starfleet rollout status deployment/shuttle
```

The rollout creates a new pod, and the old pod stops. Setting the field on the service account would also work in a real cluster, but the pod setting is the one that decides, because the pod value takes precedence. Check that no token directory is mounted:

```sh
kubectl -n starfleet get pods -l app=shuttle -o json | jq -r '.items[].spec.containers[].volumeMounts[]?.mountPath'
```

The path `/var/run/secrets/kubernetes.io/serviceaccount` no longer appears. Submit the final time:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-01/labs/lab-01 --keep
```

All five checks pass.

## Why the other answers fail

Setting `enforce` to `restricted` does not match the task, and it would reject the pods of `scout`, `probe` and `shuttle` when they restart, because they have no `securityContext`. Setting only `warn` leaves the privileged pod admitted. Deleting only the pod of `debug-tools` lets the Deployment create a new pod, which is rejected and hidden in the ReplicaSet events, while the old pod is gone. Labeling `outpost` changes a namespace that the task did not ask you to touch.

Remove the lab when you are done:

```sh
astrona destroy ats-041-lab-030-01
```
