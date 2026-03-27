#!/bin/bash

# Troubleshooting script for Todo App
set -e

echo "🔧 Todo App Kubernetes Troubleshooting"
echo "======================================"

if ! kubectl get namespace todo-app &> /dev/null; then
    echo "❌ Todo app namespace not found. App might not be deployed."
    exit 1
fi

# Function to check pod logs
check_logs() {
    local app=$1
    echo ""
    echo "📋 $app Logs (last 20 lines):"
    echo "--------------------------------"
    if kubectl get deployment $app -n todo-app &> /dev/null; then
        kubectl logs --tail=20 deployment/$app -n todo-app
    else
        echo "❌ $app deployment not found"
    fi
}

# Function to describe problematic pods
describe_pod() {
    local app=$1
    echo ""
    echo "🔍 $app Pod Description:"
    echo "------------------------"
    kubectl describe pod -l app=$app -n todo-app | grep -A 10 -B 5 "Events:\|Conditions:\|Status:"
}

echo "🩺 Checking Pod Health..."
kubectl get pods -n todo-app

# Check each component
COMPONENTS=("postgres" "redis" "backend" "frontend")

for component in "${COMPONENTS[@]}"; do
    echo ""
    echo "🔍 Checking $component..."
    
    # Check if pods are running
    POD_STATUS=$(kubectl get pods -l app=$component -n todo-app --no-headers 2>/dev/null | awk '{print $3}' | head -1)
    
    if [ "$POD_STATUS" != "Running" ]; then
        echo "⚠️  $component is not running (Status: $POD_STATUS)"
        describe_pod $component
        check_logs $component
    else
        echo "✅ $component is running"
        
        # Check readiness
        READY=$(kubectl get pods -l app=$component -n todo-app --no-headers | awk '{print $2}' | head -1)
        if [[ "$READY" != *"/"*"/"* ]] && [[ "$READY" != "1/1" ]]; then
            echo "⚠️  $component is not ready ($READY)"
            check_logs $component
        fi
    fi
done

echo ""
echo "🌐 Network Connectivity Tests:"
echo "------------------------------"

# Test backend health endpoint
echo "🔍 Testing backend health..."
if kubectl exec -n todo-app deployment/backend -- curl -f http://localhost:5000/health &> /dev/null; then
    echo "✅ Backend health endpoint responding"
else
    echo "❌ Backend health endpoint not responding"
    echo "💡 Check backend logs above"
fi

# Test database connectivity
echo ""
echo "🔍 Testing database connectivity..."
if kubectl exec -n todo-app deployment/postgres -- pg_isready -U postgres &> /dev/null; then
    echo "✅ PostgreSQL is ready"
else
    echo "❌ PostgreSQL is not ready"
    check_logs postgres
fi

# Test Redis connectivity
echo ""
echo "🔍 Testing Redis connectivity..."
if kubectl exec -n todo-app deployment/redis -- redis-cli ping | grep -q "PONG" &> /dev/null; then
    echo "✅ Redis is responding"
else
    echo "❌ Redis is not responding"
    check_logs redis
fi

echo ""
echo "📊 Resource Usage:"
echo "-----------------"
kubectl describe node | grep -A 5 "Allocated resources:" | head -10

echo ""
echo "💡 Common Solutions:"
echo "-------------------"
echo "1. Restart failing pods: kubectl delete pod -l app=<component> -n todo-app"
echo "2. Check resource limits: kubectl describe pod <pod-name> -n todo-app"
echo "3. View detailed events: kubectl get events -n todo-app --sort-by='.lastTimestamp'"
echo "4. Scale down and up: kubectl scale deployment <component> --replicas=0 -n todo-app"
echo "                     kubectl scale deployment <component> --replicas=1 -n todo-app"
echo "5. Complete restart: ./cleanup.sh && ./setup.sh"