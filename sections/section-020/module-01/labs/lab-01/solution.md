# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01
```

## Step 1: Remove the token from scout and probe

Look at what a pod can read now:

```sh
kubectl -n starfleet exec deploy/shuttle -- ls /var/run/secrets/kubernetes.io/serviceaccount
```

The listing shows `ca.crt`, `namespace` and `token`. A patch on the pod template turns the mount off. The Deployment controller then replaces the old pods:

```sh
kubectl -n starfleet patch deployment scout -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
```

The command prints `deployment.apps/scout patched` and `deployment.apps/probe patched`. Wait for both rollouts, because the old pods keep their token until they are gone:

```sh
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet rollout status deployment/probe
```

Each command ends when the Deployment is rolled out. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01 --keep
```

The check `tokens-not-mounted` now passes.

## Step 2: Block the metadata address

Save this as `networkpolicy-deny-metadata-egress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-metadata-egress
  namespace: starfleet
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

The empty `podSelector` selects all pods in the namespace. The `except` entry removes the single metadata address from the allowed range, and all other IPv4 destinations stay open. Apply it:

```sh
kubectl apply -f networkpolicy-deny-metadata-egress.yaml
```

The command prints `networkpolicy.networking.k8s.io/deny-metadata-egress created`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01 --keep
```

The check `metadata-egress-blocked` now passes. A policy with no egress rules would fail the check, because it blocks DNS and every other destination too.

## Step 3: Narrow the build-runner identity

Find out what the identity can do now:

```sh
kubectl auth can-i '*' '*' --as=system:serviceaccount:starfleet:build-runner
```

The answer is `yes`. Save this as `role-build-runner.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployment-updater
  namespace: starfleet
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: build-runner-deployment-updater
  namespace: starfleet
subjects:
  - kind: ServiceAccount
    name: build-runner
    namespace: starfleet
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployment-updater
```

Apply it, then delete the broad binding:

```sh
kubectl apply -f role-build-runner.yaml
kubectl delete clusterrolebinding build-runner-admin
```

Check the three actions that matter:

```sh
kubectl auth can-i patch deployments -n starfleet --as=system:serviceaccount:starfleet:build-runner
kubectl auth can-i delete deployments -n starfleet --as=system:serviceaccount:starfleet:build-runner
kubectl auth can-i patch deployments -n outpost --as=system:serviceaccount:starfleet:build-runner
```

The first answer is `yes`. The other two are `no`. Run the grader one last time without `--keep`:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-020/module-01/labs/lab-01
```

All five checks must pass. Then remove the lab:

```sh
astrona destroy ats-041-lab-020-01
```
