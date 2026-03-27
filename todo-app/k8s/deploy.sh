#!/bin/bash

# Kubernetes deployment script for Todo App
set -e

echo "🚀 Deploying Todo App to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if Podman images exist
echo "🔍 Checking Podman images..."
if ! podman images | grep -q "todo-backend.*v1"; then
    echo "❌ todo-backend:v1 image not found. Please build it first."
    echo "   Run: cd backend && podman build -t todo-backend:v1 -f Containerfile ."
    exit 1
fi

if ! podman images | grep -q "todo-frontend.*v1"; then
    echo "❌ todo-frontend:v1 image not found. Please build it first."
    echo "   Run: cd frontend && podman build -t todo-frontend:v1 -f Containerfile ."
    exit 1
fi

echo "✅ Images found in Podman"

# Images should already be loaded by the setup script
echo "📦 Images should already be loaded to Kubernetes cluster..."

echo "🚀 Applying Kubernetes manifests..."

# Apply manifests in order
kubectl apply -f 00-namespace.yaml
echo "✅ Namespace created"

kubectl apply -f 01-secrets.yaml
echo "✅ Secrets created"

kubectl apply -f 02-configmap.yaml
kubectl apply -f 08-postgres-init.yaml
echo "✅ ConfigMaps created"

kubectl apply -f 03-persistent-volumes.yaml
echo "✅ Persistent Volume Claims created"

kubectl apply -f 04-postgres.yaml
echo "✅ PostgreSQL deployed"

kubectl apply -f 05-redis.yaml
echo "✅ Redis deployed"

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n todo-app --timeout=120s

kubectl apply -f 06-backend.yaml
echo "✅ Backend deployed"

# Wait for backend to be ready
echo "⏳ Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n todo-app --timeout=120s

kubectl apply -f 07-frontend.yaml
echo "✅ Frontend deployed"

echo ""
echo "🎉 Todo App deployed successfully!"
echo ""
echo "📊 Checking deployment status..."
kubectl get all -n todo-app

echo ""
echo "🌐 Access the application:"
echo "   Frontend: http://localhost:30080"
echo "   Backend API: kubectl port-forward -n todo-app service/backend-service 5000:5000"
echo ""
echo "📋 Useful commands:"
echo "   Check pods: kubectl get pods -n todo-app"
echo "   Check logs: kubectl logs -f deployment/backend -n todo-app"
echo "   Scale backend: kubectl scale deployment backend --replicas=3 -n todo-app"
echo "   Delete app: kubectl delete namespace todo-app"