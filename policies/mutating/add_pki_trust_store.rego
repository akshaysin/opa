package system

    inject = {
      "apiVersion": "admission.k8s.io/v1beta1",
      "kind": "AdmissionReview",
      "response": {
        "allowed": true,
        "patchType": "JSONPatch",
        "patch": base64.encode(json.marshal(patch)),
      },
    }
    patch = [{
      "op": "add",
      "path": "/spec/InitContainers/-",
      "value": pki_container,
    }, {
      "op": "add",
      "path": "/spec/volumes/-",
      "value": {
          "name": "certs",
          "emptydir": {
            "medium": "Memory"
          }
      }
    }, {
      "op": "add",
      "path": "/spec/containers/0/volumeMounts/-",
      "value": {
           "name": "certs",
           "mountPath": "/etc/ssl/certs"
            },
    }]
    pki_container = {
    "name": "cb-certs-init",
    "image": "cloudbees/docker-certificates",
    "command": [
      "/bin/sh"
    ],
    "args": [
      "-c",
      "cp -r /etc/ssl/certs/* /tmp/certs"
    ],
    "volumeMounts": [
      {
        "name": "certs",
        "mountPath": "/tmp/certs"
      }
    ],
    "dnsPolicy": "Default"
    } {
    # Only apply mutations to objects in create/update operations (not
    # delete/connect operations.)
    is_create_or_update

    # If the resource has the "test-mutation" annotation key, the patch will be
    # generated and applied to the resource.
    input.request.object.metadata.annotations["pki"]
}

is_create_or_update { is_create }
is_create_or_update { is_update }
is_create { input.request.operation == "CREATE" }
is_update { input.request.operation == "UPDATE" }