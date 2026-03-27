# Todo App Kubernetes Deployment

This directory contains Kubernetes manifests for deploying the Todo application to a Kubernetes cluster using kubectl and Podman.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Kubernetes Cluster                     │
│  ┌─────────────────────────────────────────────────────┐ │
│  │             todo-app namespace                      │ │
│  │                                                     │ │
│  │  ┌─────────────┐    ┌─────────────┐                │ │
│  │  │  Frontend   │    │   Backend   │                │ │
│  │  │  (2 pods)   │    │   (2 pods)  │                │ │
│  │  │  Port: 80   │    │  Port: 5000 │                │ │
│  │  └─────────────┘    └─────────────┘                │ │
│  │         │                   │                       │ │
│  │         │                   │                       │ │
│  │  ┌─────────────┐    ┌─────────────┐                │ │
│  │  │ PostgreSQL  │    │    Redis    │                │ │
│  │  │   (1 pod)   │    │   (1 pod)   │                │ │
│  │  │ Port: 5432  │    │ Port: 6379  │                │ │
│  │  └─────────────┘    └─────────────┘                │ │
│  │         │                   │                       │ │
│  │  ┌─────────────┐    ┌─────────────┐                │ │
│  │  │     PVC     │    │     PVC     │                │ │
│  │  │ (postgres)  │    │  (redis)    │                │ │
│  │  └─────────────┘    └─────────────┘                │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Kubernetes cluster** (minikube, kind, or any K8s cluster)
2. **kubectl** configured to access your cluster
3. **Podman** with images built

## Quick Start

### 1. Build Images (if not already done)

```bash
# Build backend image
cd ../backend
podman build -t todo-backend:v1 -f Containerfile .

# Build frontend image  
cd ../frontend
podman build -t todo-frontend:v1 -f Containerfile .
```

### 2. Deploy to Kubernetes

```bash
cd k8s
chmod +x deploy.sh cleanup.sh
./deploy.sh
```

### 3. Access the Application

- **Frontend**: http://localhost:30080
- **Backend API**: `kubectl port-forward -n todo-app service/backend-service 5000:5000`

## Manual Deployment

If you prefer to deploy manually:

```bash
# Apply manifests in order
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-secrets.yaml
kubectl apply -f 02-configmap.yaml
kubectl apply -f 08-postgres-init.yaml
kubectl apply -f 03-persistent-volumes.yaml
kubectl apply -f 04-postgres.yaml
kubectl apply -f 05-redis.yaml

# Wait for database
kubectl wait --for=condition=ready pod -l app=postgres -n todo-app --timeout=120s

kubectl apply -f 06-backend.yaml
kubectl wait --for=condition=ready pod -l app=backend -n todo-app --timeout=120s

kubectl apply -f 07-frontend.yaml
```

## Useful Commands

```bash
# Check all resources
kubectl get all -n todo-app

# Check pod status
kubectl get pods -n todo-app -w

# View logs
kubectl logs -f deployment/backend -n todo-app
kubectl logs -f deployment/frontend -n todo-app
kubectl logs -f deployment/postgres -n todo-app

# Scale applications
kubectl scale deployment backend --replicas=3 -n todo-app
kubectl scale deployment frontend --replicas=3 -n todo-app

# Port forward for testing
kubectl port-forward -n todo-app service/backend-service 5000:5000
kubectl port-forward -n todo-app service/frontend-service 8080:80

# Exec into pods
kubectl exec -it -n todo-app deployment/postgres -- psql -U postgres -d tododb
kubectl exec -it -n todo-app deployment/redis -- redis-cli

# Check persistent volumes
kubectl get pv,pvc -n todo-app

# View secrets and configmaps
kubectl get secrets,configmaps -n todo-app
```

## Files Description

| File | Description |
|------|-------------|
| `00-namespace.yaml` | Creates the todo-app namespace |
| `01-secrets.yaml` | Database credentials and sensitive data |
| `02-configmap.yaml` | Backend configuration variables |
| `03-persistent-volumes.yaml` | PVCs for PostgreSQL and Redis data |
| `04-postgres.yaml` | PostgreSQL database deployment and service |
| `05-redis.yaml` | Redis cache deployment and service |
| `06-backend.yaml` | Node.js backend API deployment and service |
| `07-frontend.yaml` | React frontend deployment and service |
| `08-postgres-init.yaml` | Database initialization script |
| `deploy.sh` | Automated deployment script |
| `cleanup.sh` | Cleanup script to remove all resources |

## Configuration

### Secrets (base64 encoded)
- `POSTGRES_USER`: postgres
- `POSTGRES_PASSWORD`: supersecret  
- `POSTGRES_DB`: tododb

### Scaling
- Frontend: 2 replicas (can be scaled)
- Backend: 2 replicas (can be scaled)
- PostgreSQL: 1 replica (stateful)
- Redis: 1 replica (can be scaled with Redis Cluster)

### Resources
- **Backend**: 200m CPU, 256Mi RAM (requests), 500m CPU, 512Mi RAM (limits)
- **Frontend**: 50m CPU, 64Mi RAM (requests), 100m CPU, 128Mi RAM (limits)
- **PostgreSQL**: 250m CPU, 256Mi RAM (requests), 500m CPU, 512Mi RAM (limits)
- **Redis**: 100m CPU, 128Mi RAM (requests), 200m CPU, 256Mi RAM (limits)

### Storage
- PostgreSQL: 1Gi persistent volume
- Redis: 500Mi persistent volume

## Troubleshooting

### Check pod status
```bash
kubectl describe pod -l app=backend -n todo-app
```

### Database connection issues
```bash
kubectl exec -it -n todo-app deployment/postgres -- pg_isready -U postgres
```

### View all events
```bash
kubectl get events -n todo-app --sort-by='.lastTimestamp'
```

### Reset database
```bash
kubectl delete pod -l app=postgres -n todo-app
```

## Cleanup

```bash
# Remove everything
./cleanup.sh

# Or manually
kubectl delete namespace todo-app
```