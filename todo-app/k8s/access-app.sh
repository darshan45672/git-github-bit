#!/bin/bash

echo "🌐 Todo App Access Information"
echo "=============================="
echo ""

echo "🔗 Access Methods:"
echo ""

echo "1️⃣ Frontend (recommended):"
echo "   📱 Use kubectl port-forward for local access:"
echo "   kubectl port-forward -n todo-app service/frontend-service 3000:80"
echo "   🌐 Then open: http://localhost:3000"
echo ""

echo "2️⃣ Backend API:"
echo "   🔌 Use kubectl port-forward for API access:"
echo "   kubectl port-forward -n todo-app service/backend-service 5000:5000"
echo "   🔗 Then access: http://localhost:5000/health"
echo ""

echo "3️⃣ Quick Tests:"
echo "   🧪 Test backend health:"
echo "   kubectl exec -n todo-app deployment/backend -- node -e \"require('http').get('http://localhost:5000/health', (res) => console.log('Status:', res.statusCode))\""
echo ""
echo "   📊 View logs:"
echo "   kubectl logs -f -n todo-app deployment/backend"
echo "   kubectl logs -f -n todo-app deployment/frontend"
echo ""

echo "🎯 One-Click Frontend Access:"
read -p "Start frontend port-forward now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Starting port-forward for frontend..."
    echo "🌐 Frontend will be available at: http://localhost:3000"
    echo "Press Ctrl+C to stop"
    kubectl port-forward -n todo-app service/frontend-service 3000:80
fi