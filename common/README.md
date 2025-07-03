## Deploy

First install:

```bash
helm install -f grafana/values.yaml grafana ./common/
```

Update configuration:

```bash
helm upgrade -f grafana/values.yaml grafana ./common/
```
