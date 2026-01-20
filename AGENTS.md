# AGENTS.md - Homelab Kubernetes Infrastructure

This repository contains Kubernetes/Helm configuration for a homelab cluster running on Proxmox with Talos Linux nodes.

## Project Overview

- **Type**: Infrastructure as Code (IaC) - Kubernetes configurations
- **Stack**: Kubernetes, Helm, Talos Linux, Proxmox, Cloudflare Tunnel, NGINX Ingress
- **Domain**: `romeolab.uk` (all services use subdomains)
- **Cluster**: Single Proxmox host with 2 Talos nodes (1 control plane, 1 worker)

## Critical Safety Check

**BEFORE running any kubectl or helm command, verify the context:**

```bash
kubectx
```

The context MUST be `homelab`. If the output shows ANY other context:

1. **STOP IMMEDIATELY** - Do not execute any commands
2. **ALERT the user** - Report the incorrect context
3. **WAIT for confirmation** - Only proceed after user explicitly switches to `homelab`

This prevents accidental modifications to production or other clusters.

## Repository Structure

```
homelab/
├── common/                      # Reusable Helm chart (v0.2.0)
│   ├── Chart.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── pv.yaml
│       └── pvc.yaml
├── <service>/values.yaml        # Service configs using common chart
├── cloudflared/                 # Raw manifests (no common chart)
└── postgresql/                  # Raw manifests (no common chart)
```

## Commands

### Helm Deployments (services using common chart)

```bash
# Install a new service
helm install -f <service>/values.yaml <service> ./common/

# Update existing service
helm upgrade -f <service>/values.yaml <service> ./common/

# Examples
helm install -f grafana/values.yaml grafana ./common/
helm upgrade -f n8n/values.yaml n8n ./common/
```

### Raw Kubernetes Manifests

```bash
# Apply raw manifests (cloudflared, postgresql)
kubectl apply -f cloudflared/deployment.yaml
kubectl apply -f postgresql/
```

### Validation

```bash
# Lint Helm chart
helm lint ./common/

# Template a release (dry-run)
helm template <service> ./common/ -f <service>/values.yaml

# Validate YAML syntax
kubectl apply --dry-run=client -f <file>.yaml
```

## Code Style Guidelines

### YAML Formatting

- Use 2-space indentation
- No trailing whitespace
- Single blank line between major sections
- Quote string values that could be interpreted as numbers or booleans

### Values File Structure

All services using the common chart must follow this structure:

```yaml
deployment:
  name: <service-name>           # Required: matches directory name
  replicas: 1                    # Required: typically 1 for homelab
  image: <registry>/<image>:tag  # Required: full image reference
  mountName: <service>-data      # Required: volume mount name
  mountPath: /path/in/container  # Required: container mount path
  runAsNonRoot: true|false       # Optional: security context
  runAsUser: <uid>               # Optional: numeric UID
  runAsGroup: <gid>              # Optional: numeric GID
  fixPermissions:                # Optional: initContainer for chown
    command: "chown -R uid:gid /path"
  env: []                        # Optional: plain env vars
  envSecrets: []                 # Optional: env from secrets
  args: []                       # Optional: container arguments

service:
  internalPort: <port>           # Required: container port

ingress:
  host: <service>.romeolab.uk    # Required: FQDN

pv:
  name: <service>-pv             # Required: consistent naming
  path: /var/mnt/data/<service>  # Required: host path
  storage: <size>Gi              # Required: capacity
  accessModes: ReadWriteOnce     # Optional: defaults to RWO

pvc:
  name: <service>-pvc            # Required: matches PV
  storage: <size>Gi              # Required: must match PV
  accessModes: ReadWriteOnce     # Optional: defaults to RWO
```

### Naming Conventions

| Resource | Pattern | Example |
|----------|---------|---------|
| Directory | `<service>/` | `grafana/` |
| Values file | `<service>/values.yaml` | `grafana/values.yaml` |
| Deployment name | `<service>` | `grafana` |
| PersistentVolume | `<service>-pv` | `grafana-pv` |
| PersistentVolumeClaim | `<service>-pvc` | `grafana-pvc` |
| Volume mount | `<service>-data` | `grafana-data` |
| Host path | `/var/mnt/data/<service>` | `/var/mnt/data/grafana` |
| Ingress host | `<service>.romeolab.uk` | `grafana.romeolab.uk` |

### Security Requirements

All deployments MUST include these security contexts (enforced by common chart):

- `allowPrivilegeEscalation: false`
- `capabilities.drop: [ALL]`
- `seccompProfile.type: RuntimeDefault`

Prefer `runAsNonRoot: true` when the container image supports it.

### Environment Variables

```yaml
# Plain text values
env:
  - name: TZ
    value: America/Sao_Paulo

# Values from Kubernetes secrets (NEVER commit secrets)
envSecrets:
  - name: DB_PASSWORD
    secretKeyRef:
      name: postgres-secret
      key: POSTGRES_PASSWORD
```

### Image Tags

- Use specific version tags for production services: `muromeo/auth:1.1.0`
- Use `latest` only for well-established upstream images: `grafana/grafana:latest`

## Adding a New Service

1. Create directory: `mkdir <service>`
2. Create `<service>/values.yaml` following the structure above
3. Create any required Kubernetes secrets manually
4. Deploy: `helm install -f <service>/values.yaml <service> ./common/`

## Services Not Using Common Chart

Some services require raw manifests (cloudflared, postgresql) due to:
- No persistent storage needed (cloudflared)
- Custom resource requirements
- Non-standard configurations

For these, create individual YAML files in `<service>/` directory.

## Secrets Management

- Secrets are managed via `kubectl create secret` - never committed to repo
- Reference secrets in values.yaml via `envSecrets`
- Common secret names: `postgres-secret`, `jwt-secret`, `cloudflared-tunnel-token`

## Storage

- All persistent data: `/var/mnt/data/<service>` on host
- Reclaim policy: `Retain` (data preserved on PV deletion)
- Access mode: `ReadWriteOnce` (single node mounting)
