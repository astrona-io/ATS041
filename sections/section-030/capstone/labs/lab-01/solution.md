# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. A new binding needs a few seconds before the API server uses it, and the check that tests it retries for up to 20 seconds.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01
```

## Step 1: Find what baseline would reject in orbit

A server-side dry run of the label shows the pods that break the level, without changing anything:

```sh
kubectl label --dry-run=server --overwrite namespace orbit pod-security.kubernetes.io/enforce=baseline
```

The command prints a warning that names the pod of `beacon-debug`. The `relay` pod is not named, because it passes `baseline`. Enforcing the level does not remove a running pod, so the privileged pod needs its own corrective step.

## Step 2: Label orbit

`enforce` blocks at `baseline`. `warn` and `audit` report at the stricter level `restricted`. Save this as `namespace-orbit-controls.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: orbit
  labels:
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/audit: restricted
```

Apply it:

```sh
kubectl apply -f namespace-orbit-controls.yaml
```

Then check the result:

```sh
kubectl get namespace orbit --show-labels
```

Submit and see which checks pass:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01 --keep
```

The label check passes. The checks for the privileged pod, the binding and `relay` still fail.

## Step 3: Delete beacon-debug

Delete the Deployment, not only the pod, so that the Deployment controller does not create a new pod:

```sh
kubectl -n orbit delete deployment beacon-debug
```

The output is `deployment.apps "beacon-debug" deleted from orbit namespace`. Submit again:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01 --keep
```

## Step 4: Fix relay before you bind the policy

A binding in `Deny` mode also rejects an update that leaves out the limit. Patch `relay` first, so the update is accepted without a binding. One strategic merge patch sets the token setting in the pod template and the memory limit on the container named `relay`:

```sh
kubectl -n orbit patch deployment relay -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false,"containers":[{"name":"relay","resources":{"limits":{"memory":"64Mi"}}}]}}}}'
kubectl -n orbit rollout status deployment/relay
```

The rollout starts a new pod without the token. Check that no pod mounts the token path:

```sh
kubectl -n orbit get pods -l app=relay -o json | jq -r '.items[].spec.containers[].volumeMounts[]?.mountPath'
```

The path `/var/run/secrets/kubernetes.io/serviceaccount` is not in the output. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01 --keep
```

## Step 5: Bind the policy to orbit

The policy exists and has no effect without a binding. Every namespace has the label `kubernetes.io/metadata.name` with its own name, so a selector on that label picks `orbit` and no other namespace. Save this as `validatingadmissionpolicybinding-require-memory-limits-orbit.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: require-memory-limits-orbit
spec:
  policyName: require-memory-limits
  validationActions: ["Deny", "Audit"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: orbit
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicybinding-require-memory-limits-orbit.yaml
```

Then check the result with a server-side dry run of a Deployment without a limit. Wait a few seconds, and repeat if the request is still accepted:

```sh
kubectl -n orbit create deployment trial-nolimits --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
kubectl -n starfleet create deployment trial-nolimits --image=ghcr.io/stefanprodan/podinfo:6.15.0 --dry-run=server
```

The first command is rejected with `denied request` and the message of the policy. The second command succeeds, because `starfleet` is outside the scope. Submit the final time:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/capstone/labs/lab-01 --keep
```

All five checks pass.

## Why the other answers fail

Enforcing `restricted` instead of `baseline` does not match the standard, and it would reject the `relay` pod the next time it restarts. A binding with no `namespaceSelector` applies the policy to every namespace, so `starfleet` and `outpost` would reject Deployments without a limit. `Warn` instead of `Deny` lets the Deployments through. Deleting only the `beacon-debug` pod leaves its Deployment, which creates a new pod that the `enforce` label rejects.

Remove the lab when you are done:

```sh
astrona destroy ats-041-capstone-030
```
