# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01
```

## Step 1: Add the default deny and the allow policy

An empty `podSelector` selects every pod in the namespace. A policy with `policyTypes: [Ingress]` and no `ingress` rule allows nothing. Policies only add allow rules, so the second policy adds the two paths that must work. The two peers in the `from` list are alternatives (OR). The second peer holds a `namespaceSelector` and a `podSelector` in one list item, so both must match (AND). Namespaces carry the label `kubernetes.io/metadata.name` with their own name. The port is the container port 8080, not the Service port 80.

Save this as `networkpolicies-depot.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: depot
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ledger-ingress
  namespace: depot
spec:
  podSelector:
    matchLabels:
      app: ledger
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: loader
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: starfleet
          podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
```

Apply it:

```sh
kubectl apply -f networkpolicies-depot.yaml
```

The command prints `networkpolicy.networking.k8s.io/default-deny-ingress created` and the same line for `allow-ledger-ingress`. Then check the result:

```sh
kubectl get networkpolicy -n depot
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The checks `default-deny-ingress` and `ledger-allow-rules` pass.

## Step 2: Add the quota and the LimitRange

The LimitRange gives pods without resources their defaults, so that the quota on requests and limits does not reject them. Save this as `quota-and-limits-depot.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: depot-quota
  namespace: depot
spec:
  hard:
    pods: "10"
    requests.cpu: 500m
    requests.memory: 512Mi
    limits.memory: 1Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: depot-container-defaults
  namespace: depot
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 10m
        memory: 32Mi
      default:
        memory: 128Mi
      max:
        memory: 256Mi
```

Apply it:

```sh
kubectl apply -f quota-and-limits-depot.yaml
```

Then check the result:

```sh
kubectl describe resourcequota depot-quota -n depot
```

The output lists the used and hard values of each resource. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01 --keep
```

The checks `resource-quota` and `limit-range-defaults` pass.

## Step 3: Stop the token mount

A pod field would take precedence, but the pods do not set the field, so the service account decides. Patch both service accounts:

```sh
kubectl patch serviceaccount ledger -n depot -p '{"automountServiceAccountToken": false}'
kubectl patch serviceaccount loader -n depot -p '{"automountServiceAccountToken": false}'
```

Each command prints `serviceaccount/<name> patched`. Existing pods keep the token that they already have. New pods get none. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/module-02/labs/lab-01 --keep
```

All five checks pass.

## Wrong fixes the checks reject

- A `from` list with a `namespaceSelector` and a separate `podSelector` item for `shuttle`: that is OR, so `ledger` would accept every pod of `starfleet`. `ledger-allow-rules` fails.
- A rule without a `from` list or without `ports`: it allows every source or every port.
- The port 80 of the Service instead of 8080: `ledger-allow-rules` fails.
- A policy with `policyTypes: [Egress]` only: `default-deny-ingress` fails.
- A quota without `limits.memory`, or with `pods` above 10: `resource-quota` fails.
- A LimitRange without `max.memory` or without a CPU request default: `limit-range-defaults` fails.
