## Nginx

The nginx is reponsible to reverse proxy the requests to the backend services. It'll handle the ingresses.

### Installation

Add the chart repo

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

Install the chart

```bash
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.ingressClass=nginx \
  --set controller.ingressClassResource.name=nginx \
  --set controller.ingressClassResource.controllerValue="k8s.io/ingress-nginx" \
  --set controller.service.type=ClusterIP \
  --set controller.publishService.enabled=false
```

### Enable Underscores in Headers (Chatwoot fix)

By default, nginx drops HTTP headers containing underscores (like `api_access_token`). This causes 401 Unauthorized errors when Evolution API communicates with Chatwoot.

Apply the ConfigMap:

```bash
kubectl apply -f nginx/configmap.yaml
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

Verify:

```bash
kubectl get configmap ingress-nginx-controller -n ingress-nginx -o yaml | grep underscores
```
