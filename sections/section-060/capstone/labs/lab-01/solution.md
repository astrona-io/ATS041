# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01
```

Right after the start, `astrona submit` shows failing checks. The Deployment has a literal token, no container settings and no limits, there is no quota, and the service account can read Secrets.

## Step 1: Move the token into a Secret

Read the literal value from the pod template:

```sh
kubectl -n orbit get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env}'
```

Save this as `secret-beacon-credentials.yaml`, with the value you read:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: beacon-credentials
  namespace: orbit
type: Opaque
stringData:
  token: beacon-token-9
```

Apply it:

```sh
kubectl apply -f secret-beacon-credentials.yaml
```

The command prints `secret/beacon-credentials created`. Then point the variable at the Secret. A JSON patch replaces the whole entry, so the literal `value` is removed:

```sh
kubectl -n orbit patch deployment beacon --type=json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/env/0","value":{"name":"API_TOKEN","valueFrom":{"secretKeyRef":{"name":"beacon-credentials","key":"token"}}}}]'
kubectl -n orbit get deployment beacon -o jsonpath='{.spec.template.spec.containers[0].env}'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01 --keep
```

The second command prints the variable with `valueFrom` and no `value`. The check `token-from-secret` passes.

## Step 2: Harden the container and set the memory bounds

One patch sets the pod-level settings, the container settings, the memory request and limit, and the service account token mount. Pod-level fields apply to all containers. The container name is `beacon`:

```sh
kubectl -n orbit patch deployment beacon -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false,"securityContext":{"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}},"containers":[{"name":"beacon","securityContext":{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}},"resources":{"requests":{"cpu":"10m","memory":"32Mi"},"limits":{"memory":"64Mi"}}}]}}}}'
kubectl -n orbit rollout status deployment/beacon
```

The first command prints `deployment.apps/beacon patched`. If the new pod does not become ready, describe it and read the events. Then submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01 --keep
```

The checks `beacon-hardened` and the template part of `no-api-access` pass.

## Step 3: Create the ResourceQuota

Create the quota after the memory limit is set. A quota on `limits.memory` rejects pods that have no memory limit. Save this as `resourcequota-orbit.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: orbit-quota
  namespace: orbit
spec:
  hard:
    pods: "5"
    limits.memory: 512Mi
```

Apply it:

```sh
kubectl apply -f resourcequota-orbit.yaml
```

The command prints `resourcequota/orbit-quota created`. Then check the result and submit:

```sh
kubectl -n orbit describe resourcequota orbit-quota
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01 --keep
```

The `describe` output shows the `Used` and `Hard` values for `pods` and `limits.memory`. The check `beacon-bounded` passes.

## Step 4: Remove the permission to read Secrets

The Role `beacon-secrets` grants the access, and the RoleBinding `beacon-secrets` gives it to the service account. Delete the binding. The service account and the Role stay:

```sh
kubectl -n orbit delete rolebinding beacon-secrets
kubectl auth can-i list secrets -n orbit --as=system:serviceaccount:orbit:beacon
```

The first command prints `rolebinding.rbac.authorization.k8s.io "beacon-secrets" deleted`. The second prints `no`. Submit once more without `--keep` to grade the final state and remove the lab:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-060/capstone/labs/lab-01
```
