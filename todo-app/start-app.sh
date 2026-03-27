#!/bin/bash

echo "🧹 Cleaning up any existing containers..."
podman-compose down -v 2>/dev/null || true

echo "🏗️ Building all images..."
podman-compose build

echo "🚀 Starting all services..."
podman-compose up -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "🔍 Testing services..."
echo "Backend health check:"
curl -f http://localhost:5000/health || echo "❌ Backend health check failed"

echo -e "\n📋 Getting todos:"
curl -f http://localhost:5000/api/todos || echo "❌ Failed to get todos"

echo -e "\n✅ Setup complete!"
echo "🌐 Frontend: http://localhost"
echo "🔌 Backend API: http://localhost:5000/api/todos"
echo "💾 Health Check: http://localhost:5000/health"
echo ""
echo "📋 Useful commands:"
echo "  podman-compose logs -f              # View logs"
echo "  podman-compose ps                   # Check status"
echo "  podman-compose down                 # Stop services"
echo "  podman-compose down -v             # Stop and remove volumes"