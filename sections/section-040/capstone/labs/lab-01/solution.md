# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Remove the host access from courier

Read the pod template first. Look for every field that connects the pod to the node:

```sh
kubectl -n annex get deployment courier -o json | jq '.spec.template.spec | {hostNetwork, hostPID, hostIPC, automountServiceAccountToken, volumes, containers: [.containers[] | {name, securityContext, volumeMounts}]}'
```

The output shows `hostNetwork` and `hostPID` set to `true`, a `privileged` container, a `hostPath` volume named `host-run` and a mount of it. Removing only the volume mount would leave the `hostPath` volume in the pod spec, so remove both.

Save this as `deployment-courier.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: courier
  namespace: annex
  labels:
    app: courier
spec:
  replicas: 1
  selector:
    matchLabels:
      app: courier
  template:
    metadata:
      labels:
        app: courier
    spec:
      serviceAccountName: courier
      automountServiceAccountToken: false
      hostNetwork: false
      hostPID: false
      containers:
        - name: courier
          image: curlimages/curl:8.22.0
          command: ["sh", "-c", "while true; do sleep 30; done"]
          securityContext:
            privileged: false
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              memory: 32Mi
```

Apply it:

```sh
kubectl apply -f deployment-courier.yaml
```

Then check the result:

```sh
kubectl -n annex rollout status deployment/courier --timeout=180s
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The Deployment replaces the old pod with a new one, because a change to the pod template creates a new ReplicaSet. The check `courier-host-access-removed` and the check `workloads-running` pass.

## Step 2: Segment the ingress traffic

An empty `podSelector` selects every pod in the namespace. A policy with `policyTypes: [Ingress]` and no `ingress` rule allows nothing. Policies only add allow rules, so a second policy adds the one path that must work. The port is the container port 8080, not the Service port 80.

Save this as `networkpolicies-ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: annex
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-scribe-from-courier
  namespace: annex
spec:
  podSelector:
    matchLabels:
      app: scribe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: courier
      ports:
        - protocol: TCP
          port: 8080
```

Apply it:

```sh
kubectl apply -f networkpolicies-ingress.yaml
```

Then check the result:

```sh
kubectl -n annex get networkpolicy
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The list shows both policies. The check `scribe-ingress-segmented` passes. The lab grades the spec of the policies, so it does not depend on the network plugin. A policy only changes traffic when the network plugin enforces it.

## Step 3: Restrict the egress traffic of courier

When a policy selects a pod for `Egress`, the pod may send only the traffic that some egress rule allows. The pod then also loses DNS, so the policy needs a rule for DNS. The cluster DNS runs in `kube-system`, and every namespace has the label `kubernetes.io/metadata.name` with its own name. Each rule below has one `to` peer, so no peers are alternatives by accident.

Save this as `networkpolicy-courier-egress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: courier-egress
  namespace: annex
spec:
  podSelector:
    matchLabels:
      app: courier
  policyTypes:
    - Egress
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: scribe
      ports:
        - protocol: TCP
          port: 8080
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

Apply it:

```sh
kubectl apply -f networkpolicy-courier-egress.yaml
```

Then check the result:

```sh
kubectl -n annex get networkpolicy courier-egress -o json | jq '.spec.egress | length'
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The command prints `2`, one rule for `scribe` and one for DNS. The check `courier-egress-restricted` passes. An extra rule with an `ipBlock` or with no `to` field would open more destinations, and the check fails on it.

## Step 4: Cap the resources of the namespace

A ResourceQuota limits the total use of the namespace. A LimitRange sets defaults and bounds for each container. Both act at admission only, so they do not change pods that already run. A quota on `requests.memory` makes the API server reject a pod that has no memory request, unless a LimitRange sets a default. That is why the two objects go together.

Save this as `namespace-caps.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: annex-quota
  namespace: annex
spec:
  hard:
    pods: "6"
    requests.memory: 256Mi
    limits.memory: 512Mi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: annex-container-defaults
  namespace: annex
spec:
  limits:
    - type: Container
      defaultRequest:
        memory: 32Mi
      default:
        memory: 128Mi
```

Apply it:

```sh
kubectl apply -f namespace-caps.yaml
```

Then check the result:

```sh
kubectl -n annex describe resourcequota annex-quota
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-040/capstone/labs/lab-01
```

The description lists each limit with its used and hard values. The check `namespace-resource-caps` passes, and all five checks pass. The quota counts the pods and the memory of the running workloads, which stay far below the hard limits.
