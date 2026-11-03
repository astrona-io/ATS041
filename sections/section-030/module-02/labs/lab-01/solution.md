# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. A changed binding or policy needs a few seconds before the API server uses it, and the checks that test behavior retry for up to 20 seconds.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01
```

## Step 1: Read the control as it is

Look at the binding and the policy before you change them:

```sh
kubectl get validatingadmissionpolicybinding require-memory-limits-binding -o yaml
kubectl get validatingadmissionpolicy require-memory-limits -o yaml
```

The binding has `validationActions: [Warn]` and a `namespaceSelector` that needs the label `control-scope: in-scope`. The namespace `starfleet` does not have that label. The expression of the policy reads `resources.requests`, although the message and the task talk about limits. These are the three faults.

## Step 2: Make the binding block

`Deny` rejects the request and `Audit` records the failure. `Deny` and `Warn` cannot be used together, so the patch replaces the whole list:

```sh
kubectl patch validatingadmissionpolicybinding require-memory-limits-binding --type=merge -p '{"spec":{"validationActions":["Deny","Audit"]}}'
```

The output is `validatingadmissionpolicybinding.admissionregistration.k8s.io/require-memory-limits-binding patched`. Submit and see which checks pass:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01 --keep
```

The check for the `Deny` action passes. The behavior checks still fail, because the binding does not select `starfleet` yet.

## Step 3: Put starfleet in the scope

The binding selects namespaces with the label `control-scope=in-scope`. Add the label to `starfleet` only:

```sh
kubectl label namespace starfleet control-scope=in-scope
```

The output is `namespace/starfleet labeled`. Do not label `outpost`: the task says the control must stay out of it. Submit again after a few seconds:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01 --keep
```

The check that a Deployment without a limit is rejected in `starfleet` passes now. The check about limits and requests still fails, because the expression reads the wrong field.

## Step 4: Correct the expression

Save this as `validatingadmissionpolicy-require-memory-limits.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: require-memory-limits
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.template.spec.containers.all(c, has(c.resources) && has(c.resources.limits) && 'memory' in c.resources.limits)"
      message: "Every container must set resources.limits.memory."
      reason: Invalid
```

Apply it:

```sh
kubectl apply -f validatingadmissionpolicy-require-memory-limits.yaml
```

Then check the result. A Deployment with `requests.memory` only must now be rejected, and one with `limits.memory` must be accepted. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01 --keep
```

## Step 5: Give probe a memory limit

The `probe` Deployment was created before the control existed, so it keeps running. Any update that leaves out the limit is rejected now, so add the limit in the pod template. A strategic merge patch changes the container with the name `probe` and keeps the rest:

```sh
kubectl -n starfleet patch deployment probe -p '{"spec":{"template":{"spec":{"containers":[{"name":"probe","resources":{"limits":{"memory":"64Mi"}}}]}}}}'
kubectl -n starfleet rollout status deployment/probe
```

The patch is accepted because the new object passes the policy. Check the result:

```sh
kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

The output shows the memory limit together with the request that was already set. Submit the final time:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS041.git -c sections/section-030/module-02/labs/lab-01 --keep
```

All five checks pass.

## Why the other answers fail

Labeling `outpost` or removing the selector from the binding puts `outpost` in scope, and the task says that it must stay out. Replacing `Warn` with `Deny` and `Warn` together is refused by the API server. Changing only the binding leaves the wrong field in the expression, so a Deployment with a limit and no request would be rejected and one with a request and no limit would pass. Deleting `probe` breaks the rule that no Deployment is deleted.

Remove the lab when you are done:

```sh
astrona destroy ats-041-lab-030-02
```
