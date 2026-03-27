#!/bin/bash

# Monitoring and status checking script for Todo App
set -e

echo "📊 Todo App Kubernetes Status"
echo "============================="

# Check if namespace exists
if ! kubectl get namespace todo-app &> /dev/null; then
    echo "❌ Todo app is not deployed. Run ./setup.sh first."
    exit 1
fi

echo "🔍 Namespace: todo-app"
echo ""

# Get all resources
echo "📋 All Resources:"
kubectl get all -n todo-app

echo ""
echo "💾 Storage:"
kubectl get pvc -n todo-app

echo ""
echo "🔐 Secrets & ConfigMaps:"
kubectl get secrets,configmaps -n todo-app

echo ""
echo "🏃 Pod Status Details:"
kubectl get pods -n todo-app -o wide

echo ""
echo "🌐 Service Endpoints:"
kubectl get endpoints -n todo-app

echo ""
echo "📊 Resource Usage:"
if kubectl top pods -n todo-app &> /dev/null; then
    kubectl top pods -n todo-app
else
    echo "⚠️  Metrics server not available"
fi

echo ""
echo "🔗 Access Information:"
echo "   Frontend (NodePort): http://localhost:30080"
echo "   Backend API: kubectl port-forward -n todo-app service/backend-service 5000:5000"

echo ""
echo "📝 Recent Events:"
kubectl get events -n todo-app --sort-by='.lastTimestamp' | tail -10

# Check if all pods are ready
echo ""
echo "✅ Health Check:"
NOT_READY=$(kubectl get pods -n todo-app --no-headers | grep -v "Running\|Completed" | wc -l)
if [ $NOT_READY -eq 0 ]; then
    echo "🎉 All pods are running!"
else
    echo "⚠️  Some pods are not ready. Check the status above."
fi