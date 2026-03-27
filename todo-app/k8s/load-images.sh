#!/bin/bash

# Script to load Podman images into Kubernetes cluster
# This script handles different Kubernetes environments (minikube, kind, etc.)

set -e

echo "🔄 Loading Podman images into Kubernetes cluster..."

# Function to detect Kubernetes environment
detect_k8s_env() {
    if kubectl config current-context | grep -q "minikube"; then
        echo "minikube"
    elif kubectl config current-context | grep -q "kind"; then
        echo "kind"
    elif command -v podman-desktop &> /dev/null; then
        echo "podman-desktop"
    else
        echo "unknown"
    fi
}

# Function to load images based on environment
load_images() {
    local env=$1
    
    case $env in
        "minikube")
            echo "📦 Loading images to minikube..."
            # Save and load to minikube
            podman save todo-backend:v1 | minikube image load --
            podman save todo-frontend:v1 | minikube image load --
            ;;
        "kind")
            echo "📦 Loading images to kind cluster..."
            # Get the actual kind cluster name from current context
            CLUSTER_NAME=$(kubectl config current-context | sed 's/kind-//')
            echo "🔍 Using kind cluster: $CLUSTER_NAME"
            
            # Save Podman images and load to kind cluster
            echo "💾 Saving and loading backend image..."
            podman save todo-backend:v1 -o backend-image.tar
            kind load image-archive backend-image.tar --name="$CLUSTER_NAME"
            rm backend-image.tar
            
            echo "💾 Saving and loading frontend image..."  
            podman save todo-frontend:v1 -o frontend-image.tar
            kind load image-archive frontend-image.tar --name="$CLUSTER_NAME"
            rm frontend-image.tar
            ;;
        "podman-desktop")
            echo "📦 Images should be available in Podman Desktop Kubernetes..."
            # Podman Desktop usually shares images automatically
            echo "✅ No additional loading needed for Podman Desktop"
            ;;
        *)
            echo "⚠️  Unknown Kubernetes environment. Trying generic approach..."
            echo "💡 Make sure your K8s cluster can access Podman images"
            echo "   You might need to:"
            echo "   1. Push images to a registry"
            echo "   2. Use 'imagePullPolicy: Never' in deployments"
            echo "   3. Manually load images using your cluster's method"
            ;;
    esac
}

# Check if images exist
if ! podman images | grep -q "todo-backend:v1"; then
    echo "❌ todo-backend:v1 image not found. Building it..."
    cd ../backend
    podman build -t todo-backend:v1 -f Containerfile .
    cd ../k8s
fi

if ! podman images | grep -q "todo-frontend:v1"; then
    echo "❌ todo-frontend:v1 image not found. Building it..."
    cd ../frontend
    podman build -t todo-frontend:v1 -f Containerfile .
    cd ../k8s
fi

# Detect environment and load images
K8S_ENV=$(detect_k8s_env)
echo "🔍 Detected Kubernetes environment: $K8S_ENV"

load_images $K8S_ENV

echo "✅ Image loading completed!"