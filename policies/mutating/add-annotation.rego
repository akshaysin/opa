package system

main = {
    "apiVersion": "admission.k8s.io/v1beta1",
    "kind": "AdmissionReview",
    "response": {
        "allowed": true,

        # kube-apiserver only supports JSON Patch today.
        "patchType": "JSONPatch",

        # kube-apiserver expects changes to be represented as JSON Patch
        # operations against the resource. The JSON Patch must be JSON
        # serialized and base64 encoded.
        "patch": base64url.encode(json.marshal([
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject", "value": "true"},
        ])),
    }
} {
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # If the resource has the "test-mutation" annotation key, the patch will be
    # generated and applied to the resource.
    input.request.object.metadata.annotations["ms.com~1vault-inject-status"]
}

is_create_or_update { is_create }
is_create_or_update { is_update }
is_create { input.request.operation == "CREATE" }
is_update { input.request.operation == "UPDATE" }
