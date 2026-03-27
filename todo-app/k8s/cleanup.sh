#!/bin/bash

# Kubernetes cleanup script for Todo App
set -e

echo "🧹 Cleaning up Todo App from Kubernetes..."

# Delete the entire namespace (this removes all resources)
kubectl delete namespace todo-app --ignore-not-found=true

echo "✅ Todo App removed from Kubernetes cluster"

# Optional: Clean up Podman images
read -p "🗑️  Do you want to remove Podman images as well? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    podman rmi todo-backend:v1 todo-frontend:v1 --ignore
    echo "✅ Podman images removed"
fi

echo "🎉 Cleanup completed!"