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
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject1", "value": "true"},
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject2", "value": "true"},
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject3", "value": "true"},
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject4", "value": "true"},
            {"op": "add", "path": "/metadata/annotations/vault.hasicorp.com~1agent-inject5", "value": "true"},
        ])),
    }
} {
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # If the resource does not have has the "vault-inject-status" and "krb5.keytab" annotation key, the patch will be
    # generated and applied to the resource.
    not input.request.object.metadata.annotations["vault-inject-status"]
    not input.request.object.metadata.annotations["krb5.keytab"]
} {
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # If the resource does not have has the "vault-inject-status" and "krb5.ccache" annotation key, the patch will be
    # generated and applied to the resource.
    not input.request.object.metadata.annotations["vault-inject-status"]
    not input.request.object.metadata.annotations["krb5.ccache"]
} {
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # If the resource does not have has the "vault-inject-status" and "pki.cert" annotation key, the patch will be
    # generated and applied to the resource.
    not input.request.object.metadata.annotations["vault-inject-status"]
    not input.request.object.metadata.annotations["pki.cert"]
}

is_create_or_update { is_create }
is_create_or_update { is_update }
is_create { input.request.operation == "CREATE" }
is_update { input.request.operation == "UPDATE" }
