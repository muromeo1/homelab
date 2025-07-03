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
