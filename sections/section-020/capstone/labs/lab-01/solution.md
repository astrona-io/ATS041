# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01
```

## Step 1: Remove the token and the cluster-admin binding

A patch on the pod template switches the token mount off, and the Deployment controller replaces the old pod:

```sh
kubectl -n outpost patch deployment drifter -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n outpost rollout status deployment/drifter
```

The old pod keeps its token until the rollout finishes. Now replace the broad grant. Save this as `role-drifter-configmaps.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader
  namespace: outpost
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-configmap-reader
  namespace: outpost
subjects:
  - kind: ServiceAccount
    name: drifter
    namespace: outpost
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: configmap-reader
```

Apply it and delete the binding that grants `cluster-admin`:

```sh
kubectl apply -f role-drifter-configmaps.yaml
kubectl delete clusterrolebinding drifter-admin
```

Check the identity:

```sh
kubectl auth can-i '*' '*' --as=system:serviceaccount:outpost:drifter
kubectl auth can-i list configmaps -n outpost --as=system:serviceaccount:outpost:drifter
```

The first answer is `no` and the second is `yes`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01 --keep
```

The checks `drifter-token-removed` and `drifter-least-privilege` now pass.

## Step 2: Block the metadata address

Save this as `networkpolicy-deny-metadata-egress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-metadata-egress
  namespace: outpost
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 169.254.169.254/32
```

Apply it:

```sh
kubectl apply -f networkpolicy-deny-metadata-egress.yaml
```

The command prints `networkpolicy.networking.k8s.io/deny-metadata-egress created`. A policy with no egress rules would block DNS too, so it fails the check. Grade it with `astrona submit ... --keep` as in the first step:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01 --keep
```

The check `metadata-egress-blocked` now passes.

## Step 3: Remove anonymous access

Ask the API server what an unauthenticated caller may do, and find the binding:

```sh
kubectl auth can-i list pods -n outpost --as=system:anonymous --as-group=system:unauthenticated
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[]? | .name == "system:unauthenticated") | .metadata.name + " -> " + .roleRef.name'
```

The answer is `yes`, and the list names the built-in `system:public-info-viewer` and the binding `outpost-public-view`. Delete only the second one:

```sh
kubectl delete clusterrolebinding outpost-public-view
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01 --keep
```

The check `anonymous-access-removed` now passes.

## Step 4: Remove the host path and enforce baseline

A server-side dry run shows what the label would do:

```sh
kubectl label --dry-run=server --overwrite namespace outpost pod-security.kubernetes.io/enforce=baseline
```

The command warns that the `drifter-hostmount` pod violates the level. Delete its Deployment and enforce the level:

```sh
kubectl -n outpost delete deployment drifter-hostmount
kubectl label --overwrite namespace outpost pod-security.kubernetes.io/enforce=baseline
```

The second command prints `namespace/outpost labeled`. Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/capstone/labs/lab-01
```

All five checks must pass. Then remove the lab:

```sh
astrona destroy ats-041-capstone-020
```
