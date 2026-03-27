#!/bin/bash

# Complete setup script for Todo App Kubernetes deployment
set -e

echo "🚀 Todo App Kubernetes Complete Setup"
echo "====================================="

# Step 1: Check prerequisites
echo "1️⃣ Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

if ! command -v podman &> /dev/null; then
    echo "❌ Podman is not installed. Please install Podman first."
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    echo "💡 For minikube: minikube start"
    echo "💡 For kind: kind create cluster"
    exit 1
fi

echo "✅ Prerequisites checked"

# Step 2: Build images if needed
echo ""
echo "2️⃣ Building Docker images..."

cd ..

if ! podman images | grep -q "todo-backend:v1"; then
    echo "🔨 Building backend image..."
    cd backend
    podman build -t todo-backend:v1 -f Containerfile .
    cd ..
else
    echo "✅ Backend image exists"
fi

if ! podman images | grep -q "todo-frontend:v1"; then
    echo "🔨 Building frontend image..."
    cd frontend
    podman build -t todo-frontend:v1 -f Containerfile .
    cd ..
else
    echo "✅ Frontend image exists"
fi

cd k8s

# Step 3: Load images to Kubernetes
echo ""
echo "3️⃣ Loading images to Kubernetes cluster..."
./load-images.sh

# Step 4: Deploy application
echo ""
echo "4️⃣ Deploying application to Kubernetes..."
./deploy.sh

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Wait for all pods to be ready: kubectl get pods -n todo-app -w"
echo "   2. Access frontend: http://localhost:30080"
echo "   3. Test backend: kubectl port-forward -n todo-app service/backend-service 5000:5000"
echo ""
echo "🛠️ Management commands:"
echo "   - View status: kubectl get all -n todo-app"
echo "   - View logs: kubectl logs -f deployment/backend -n todo-app"
echo "   - Scale app: kubectl scale deployment backend --replicas=3 -n todo-app"
echo "   - Cleanup: ./cleanup.sh"