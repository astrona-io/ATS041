# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written without running the lab, so the text does not show command output except where the Kubernetes behavior makes it certain.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-02/labs/lab-01
```

## Step 1: Write the policy

A `ValidatingAdmissionPolicy` holds the rule, written in the Common Expression Language (CEL). The variable `images` collects the images of the containers and, when the pod has them, of the init containers. The `has()` macro avoids an error when the pod has no `initContainers`. Both prefixes end with a slash, so a look-alike host name does not match.

Save this as `validatingadmissionpolicy-approved-registries.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: approved-registries
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: [""]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["pods"]
  variables:
    - name: images
      expression: >-
        object.spec.containers.map(c, c.image) +
        (has(object.spec.initContainers) ? object.spec.initContainers.map(c, c.image) : [])
  validations:
    - expression: >-
        variables.images.all(i,
        i.startsWith('registry.starfleet.example/') || i.startsWith('ghcr.io/stefanprodan/'))
      message: "Images must come from registry.starfleet.example/ or ghcr.io/stefanprodan/."
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicy-approved-registries.yaml
```

Nothing is enforced yet, because a policy without a binding does nothing. The check `policy-and-binding-defined` still fails.

## Step 2: Bind it to dockyard

The binding selects the namespace by its automatic label `kubernetes.io/metadata.name` and sets the action `Deny`.

Save this as `validatingadmissionpolicybinding-approved-registries-dockyard.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: approved-registries-dockyard
spec:
  policyName: approved-registries
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: dockyard
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicybinding-approved-registries-dockyard.yaml
```

Then check the result. The policy needs a few seconds before the API server enforces it, so repeat the first command if it is accepted at first. A denied request names the policy and the binding:

```sh
kubectl -n dockyard run denied-check --image=docker.io/library/busybox:1.37 --dry-run=server
kubectl -n outpost run allowed-check --image=docker.io/library/busybox:1.37 --dry-run=server
```

The first command fails with an error that contains `ValidatingAdmissionPolicy 'approved-registries' with binding 'approved-registries-dockyard' denied request`. The second command succeeds, because `outpost` is not selected.

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-050/module-02/labs/lab-01
```

All five checks pass. The policy never touches the Deployment `stray`, because the policy matches pods only and the Deployment already exists with zero replicas.

Finally remove the lab:

```sh
astrona destroy ats-041-lab-050-02
```
