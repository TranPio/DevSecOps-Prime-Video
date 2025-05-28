#!/bin/bash
echo "========================================"
echo "🐳 DOCKER HEALTH CHECK SCRIPT"
echo "========================================"

echo ""
echo "1. 📋 DOCKER VERSION & STATUS"
echo "----------------------------------------"
echo "Docker Version:"
docker --version 2>/dev/null || echo "❌ Docker not installed"

echo ""
echo "Docker Service Status:"
sudo systemctl is-active docker 2>/dev/null || echo "❌ Docker service not running"

echo ""
echo "2. 🔐 DOCKER AUTHENTICATION"
echo "----------------------------------------"
echo "Docker Login Status:"
if docker system info | grep -q Username; then
    echo "✅ Logged in to Docker Hub"
    docker system info | grep Username
else
    echo "❌ Not logged in to Docker Hub"
fi

echo ""
echo "3. 👤 USER PERMISSIONS"
echo "----------------------------------------"
echo "Current user groups:"
groups $USER

echo ""
echo "Docker group members:"
getent group docker 2>/dev/null || echo "❌ Docker group not found"

echo ""
echo "Docker socket permissions:"
ls -la /var/run/docker.sock 2>/dev/null || echo "❌ Docker socket not found"

echo ""
echo "4. 🐳 DOCKER CONTAINERS & IMAGES"
echo "----------------------------------------"
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "❌ Cannot list containers"

echo ""
echo "All containers:"
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || echo "❌ Cannot list containers"

echo ""
echo "Docker images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "❌ Cannot list images"

echo ""
echo "5. 🌐 DOCKER NETWORK & STORAGE"
echo "----------------------------------------"
echo "Docker networks:"
docker network ls 2>/dev/null || echo "❌ Cannot list networks"

echo ""
echo "Docker disk usage:"
docker system df 2>/dev/null || echo "❌ Cannot check disk usage"

echo ""
echo "6. ⚙️ DOCKER SYSTEM INFO"
echo "----------------------------------------"
echo "Docker info summary:"
docker info --format "{{.ServerVersion}}" 2>/dev/null && echo "✅ Docker daemon running" || echo "❌ Docker daemon not accessible"

echo ""
echo "Storage Driver:"
docker info --format "{{.Driver}}" 2>/dev/null || echo "❌ Cannot get storage info"

echo ""
echo "7. 🧪 DOCKER FUNCTIONALITY TEST"
echo "----------------------------------------"
echo "Testing Docker with hello-world:"
if docker run --rm hello-world >/dev/null 2>&1; then
    echo "✅ Docker is working correctly"
else
    echo "❌ Docker test failed"
fi

echo ""
echo "========================================"
echo "🎯 DOCKER CHECK COMPLETED"
echo "========================================"
