kubectl create ns opa

cd certs
kubectl create secret tls opa-server --cert=server.crt --key=server.key --namespace opa

cat > mutating-webhook-configuration.yaml <<EOF
kind: MutatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1beta1
metadata:
  name:  opa-mutating-webhook
webhooks:
  - name: mutating-webhook.openpolicyagent.org
    namespaceSelector:
      matchExpressions:
      - key: openpolicyagent.org/webhook
        operator: NotIn
        values:
        - ignore
    rules:
      - operations: ["*"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
      service:
        namespace: opa
        name: opa
EOF

mv mutating-webhook-configuration.yaml ../opa-core/

cd ..

kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore


