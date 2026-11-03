---
draft: true
exam_objectives:
  - Isolation Techniques
---
# Resource And Identity Limits

A segment is not only a set of allowed network paths. One tenant can also starve its neighbours by taking all the CPU and memory of a node, or reach the API with a credential it never needed. Network rules do nothing against either problem. This part covers the controls for resources, `ResourceQuota` and `LimitRange`, and the controls for identity, service accounts and token mounting.

## Why resources are part of isolation

A container that uses more memory than the node has free can cause the kernel to stop other processes. A container that uses all the CPU slows every pod on the node. The exam calls this a denial of service between tenants. Resource limits are the control, and they work at two levels: a limit on one container and a limit on a whole namespace.

Each container can declare `resources.requests` and `resources.limits`. A **request** is the amount the scheduler reserves for the container when it chooses a node. A **limit** is the maximum the container may use. The kubelet and the container runtime enforce the limit with a control group. A container above its memory limit is stopped by the kernel. A container above its CPU limit is slowed down, not stopped.

A developer can forget to set them. A pod with no memory limit can take as much memory as the node has. Kubernetes therefore offers two admission controls that set rules per namespace.

## LimitRange: defaults and bounds for one container

A **LimitRange** is a namespaced object that sets default values and allowed ranges for the containers and pods of its namespace. The admission controller `LimitRanger` reads it when a pod is created. In the `limits` list, an entry of type `Container` can hold these fields:

- `defaultRequest` is the request given to a container that sets none.
- `default` is the limit given to a container that sets none.
- `min` and `max` are the smallest and largest values a container may ask for. A pod outside the range is rejected with a `403 Forbidden` error.

A LimitRange acts only when a pod is created. It does not change pods that already run, and a change to it does not touch them either.

## ResourceQuota: a cap for the whole namespace

A **ResourceQuota** is a namespaced object whose `spec.hard` map sets a cap on the total in the namespace. The totals can be compute resources such as `requests.cpu`, `requests.memory` and `limits.memory`, and object counts such as `pods`. When a request would push the total over the cap, the API server rejects it with `403 Forbidden` and an `exceeded quota` message. Existing objects are not affected.

The two objects work together. If a quota covers `requests.memory` or `limits.memory`, every new pod must state those values, because the quota system has to add them up. A pod that states nothing can be rejected. A LimitRange in the same namespace gives such pods defaults, so they are admitted.

## Set both in a trial namespace

The playground has an empty namespace, `trial`. The quick test pods below use its `default` service account only because they are short-lived test pods.

<!-- astrona:playground:renew -->

Save this as `limitrange-trial-defaults.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: trial
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
kubectl apply -f limitrange-trial-defaults.yaml
```

Then check the result by creating a pod that sets no resources and reading what the pod got:

```sh
kubectl run defaults-check --image=curlimages/curl:8.22.0 -n trial --command -- sleep 3600
kubectl get pod defaults-check -n trial -o jsonpath='{.spec.containers[0].resources}'
```

The second command prints the values of the LimitRange: a memory limit of `128Mi` and requests of `10m` CPU and `32Mi` memory. The LimitRange admission controller added them while the pod was created. Now save this as `resourcequota-trial.yaml`. It allows at most two pods in the namespace:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: trial-quota
  namespace: trial
spec:
  hard:
    pods: "2"
    requests.memory: 256Mi
    limits.memory: 512Mi
```

Apply it:

```sh
kubectl apply -f resourcequota-trial.yaml
```

Then check the result. Create two more pods and read the quota usage:

```sh
kubectl run second-check --image=curlimages/curl:8.22.0 -n trial --command -- sleep 3600
kubectl run third-check --image=curlimages/curl:8.22.0 -n trial --command -- sleep 3600
kubectl describe resourcequota trial-quota -n trial
```

The second pod is accepted, because the namespace then holds two pods. The third command fails with a `Forbidden` error that says `exceeded quota`, and it names the quota, the requested amount, the used amount and the limit. The `describe` output shows the used and hard values side by side. The pod `defaults-check` was created before the quota, and the quota did not touch it.

## Identity limits

Resource caps do not limit what a pod can do with a credential. Three controls limit identity. First, every workload runs as its own service account, never as the `default` account, so that rights can be granted per workload. Second, the service account gets only the rights its workload needs. Third, a workload that never calls the API sets `automountServiceAccountToken: false`, either on the pod or on the service account. If the pod field and the account field differ, the pod field wins.

A related setting is `imagePullSecrets`. It lists the secrets that the kubelet uses to pull images from a private registry. A pod in `starfleet` cannot use an image pull secret that lives in `outpost`, because secrets are namespaced. That is one more example of the namespace acting as a scope that a control relies on.

Check the setting in the pod that you created above. A service account of a pod in `trial` still gets a token unless you turn it off:

```sh
kubectl get pod defaults-check -n trial -o jsonpath='{.spec.automountServiceAccountToken}'
```

The command prints nothing, because the field is not set on the pod, and the `default` account of `trial` does not set it either. Without a value, the kubelet mounts the token.

You now know how a namespace gets a cap on total use, how a LimitRange fills in missing values, and where the identity of a pod is limited. What remains is the boundary of the node and the kernel itself.

## Common pitfalls

> [!WARNING]
> A ResourceQuota on requests or limits can reject pods that state no values, unless a LimitRange gives defaults. A quota or a LimitRange never changes existing pods. A Deployment can be created even when its pods exceed the quota; the error appears in the events of the ReplicaSet. A CPU limit slows a container down and a memory limit stops it. Quotas do not protect a shared database from expensive requests.
