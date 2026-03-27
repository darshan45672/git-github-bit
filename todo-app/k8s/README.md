# 🚀 Todo App Kubernetes Deployment

A complete full-stack Todo application deployed on Kubernetes using kubectl and Podman. This project demonstrates modern containerized application deployment with production-ready configurations.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   PostgreSQL    │
│   (React)       │◄──►│  (Node.js)      │◄──►│   Database      │
│   Nginx         │    │   Express       │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │              ┌─────────────────┐
         │                       │              │     Redis       │
         │                       └─────────────►│    Cache        │
         │                                      │                 │
         │                                      └─────────────────┘
         │
┌─────────────────┐
│   Kubernetes    │
│   Services &    │
│   Networking    │
└─────────────────┘
```

### Kubernetes Architecture
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

## 🛠️ Components

- **Frontend**: React application served by Nginx
- **Backend**: Node.js REST API with Express
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis for performance optimization
- **Orchestration**: Kubernetes with kubectl
- **Containerization**: Podman for building images

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

1. **Kubernetes cluster** (minikube, kind, or any K8s cluster)
2. **kubectl** configured to access your cluster
3. **Podman** with images built

### Installation Check
```bash
# Verify installations
kubectl version --client
podman --version

# Check cluster connectivity
kubectl cluster-info
```

## 🚀 Quick Start

### Method 1: One-Command Setup (Recommended)
```bash
# Complete automated setup
./setup.sh
```

This script will:
- ✅ Check prerequisites
- 🔨 Build Docker images with Podman
- 📦 Load images to Kubernetes cluster
- 🚀 Deploy all components
- 🎯 Configure networking and services

### Method 2: Manual Step-by-Step

#### Step 1: Build Images
```bash
# Navigate to project root
cd ..

# Build backend image
cd backend
podman build -t todo-backend:v1 -f Containerfile .

# Build frontend image  
cd ../frontend
podman build -t todo-frontend:v1 -f Containerfile .

cd ../k8s
```

#### Step 2: Load Images to Kubernetes
```bash
# Load images to your cluster
./load-images.sh
```

#### Step 3: Deploy Components
```bash
# Deploy all Kubernetes manifests
./deploy.sh
```

#### Step 4: Verify Deployment
```bash
# Check all resources
kubectl get all -n todo-app

# View pod status
kubectl get pods -n todo-app -w
```

## 🌐 Accessing the Application

### Frontend Access
```bash
# Interactive access helper (recommended)
./access-app.sh

# Manual port forwarding
kubectl port-forward -n todo-app service/frontend-service 3000:80

# Open in browser
open http://localhost:3000
```

### Backend API Access
```bash
# Start port forwarding for API
kubectl port-forward -n todo-app service/backend-service 5000:5000

# Test health endpoint
curl http://localhost:5000/health
```

### API Endpoints
- `GET /api/todos` - List all todos
- `POST /api/todos` - Create new todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `GET /health` - Health check

## 🔍 Monitoring and Management

### Check Application Status
```bash
# Comprehensive status check
./status.sh

# Quick pod status
kubectl get pods -n todo-app

# View logs
kubectl logs -f deployment/backend -n todo-app
kubectl logs -f deployment/frontend -n todo-app
```

### Scaling Applications
```bash
# Scale backend replicas
kubectl scale deployment backend --replicas=3 -n todo-app

# Scale frontend replicas
kubectl scale deployment frontend --replicas=3 -n todo-app

# Verify scaling
kubectl get deployment -n todo-app
```

## 🔧 Troubleshooting

### Automated Diagnostics
```bash
# Run comprehensive troubleshooting
./troubleshoot.sh
```

### Common Issues and Solutions

#### 1. Pods Not Starting
```bash
# Check pod status
kubectl get pods -n todo-app

# View pod details
kubectl describe pod <pod-name> -n todo-app

# Check logs
kubectl logs <pod-name> -n todo-app
```

#### 2. Image Pull Errors
```bash
# Verify images are loaded
podman images | grep todo

# Reload images if needed
./load-images.sh
```

#### 3. Database Connection Issues
```bash
# Check PostgreSQL status
kubectl exec -n todo-app deployment/postgres -- pg_isready -U postgres

# Verify secrets
kubectl get secrets -n todo-app
```

### Advanced Troubleshooting
```bash
# View recent events
kubectl get events -n todo-app --sort-by='.lastTimestamp'

# Debug networking
kubectl exec -n todo-app deployment/backend -- nslookup postgres-service

# Resource constraints
kubectl describe node
```

## 📁 Project Structure

```
k8s/
├── 00-namespace.yaml          # Namespace definition
├── 01-secrets.yaml           # Database and app secrets
├── 02-configmap.yaml         # Backend configuration
├── 03-persistent-volumes.yaml # Storage claims
├── 04-postgres.yaml          # PostgreSQL deployment
├── 05-redis.yaml             # Redis deployment
├── 06-backend.yaml           # Backend API deployment
├── 07-frontend.yaml          # Frontend deployment
├── 08-postgres-init.yaml     # Database initialization
├── setup.sh                  # Complete setup script
├── deploy.sh                 # Deployment script
├── load-images.sh            # Image loading script
├── access-app.sh             # Application access helper
├── status.sh                 # Status monitoring
├── troubleshoot.sh           # Diagnostics script
├── cleanup.sh                # Cleanup script
└── README.md                 # This documentation
```

## ⚙️ Configuration

### Environment Variables (Backend)
- `PORT` - Server port (default: 5000)
- `DB_HOST` - PostgreSQL host
- `DB_PORT` - PostgreSQL port (default: 5432)
- `DB_USER` - Database username
- `DB_NAME` - Database name
- `DB_PASSWORD` - Database password
- `REDIS_HOST` - Redis host
- `NODE_ENV` - Environment (development/production)

### Kubernetes Resources
- **Namespace**: `todo-app`
- **Replicas**: 2 (frontend & backend)
- **Storage**: Persistent volumes for database and cache
- **Networking**: ClusterIP services with NodePort for frontend
- **Security**: Non-root containers, resource limits

## 🧹 Cleanup

### Complete Cleanup
```bash
# Remove everything (recommended)
./cleanup.sh
```

### Manual Cleanup
```bash
# Delete namespace (removes all resources)
kubectl delete namespace todo-app

# Remove Podman images
podman rmi todo-backend:v1 todo-frontend:v1
```

## 🔄 Development Workflow

### Making Changes

1. **Update Code**: Modify your application code
2. **Rebuild Images**: 
   ```bash
   cd backend && podman build -t todo-backend:v1 -f Containerfile .
   cd ../frontend && podman build -t todo-frontend:v1 -f Containerfile .
   ```
3. **Reload Images**: `./load-images.sh`
4. **Update Deployment**: 
   ```bash
   kubectl rollout restart deployment/backend -n todo-app
   kubectl rollout restart deployment/frontend -n todo-app
   ```

### Testing Changes
```bash
# Watch rollout status
kubectl rollout status deployment/backend -n todo-app

# Verify new pods
kubectl get pods -n todo-app

# Check application
curl http://localhost:5000/health
```

## 📊 Production Considerations

### Security
- Non-root containers
- Resource limits configured
- Secrets for sensitive data
- Network policies (can be added)

### High Availability
- Multiple replicas for critical services
- Persistent storage for data
- Health checks and probes
- Rolling updates

### Monitoring
- Structured logging
- Health endpoints
- Resource monitoring
- Event tracking

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Podman Documentation](https://podman.io/getting-started/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/)
- [React Documentation](https://reactjs.org/docs/)

## 🏷️ Tags

`kubernetes` `k8s` `podman` `docker` `nodejs` `react` `postgresql` `redis` `microservices` `containerization` `devops` `todo-app`
