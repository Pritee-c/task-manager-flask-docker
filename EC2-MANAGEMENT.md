# Task Manager EC2 Management Commands

## Application Management
```bash
# Navigate to application directory
cd /home/ubuntu/task-manager

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View all logs
docker-compose -f docker-compose.prod.yml logs

# View logs for specific service
docker-compose -f docker-compose.prod.yml logs backend
docker-compose -f docker-compose.prod.yml logs frontend
docker-compose -f docker-compose.prod.yml logs db

# Follow logs in real-time
docker-compose -f docker-compose.prod.yml logs -f

# Restart all services
docker-compose -f docker-compose.prod.yml restart

# Restart specific service
docker-compose -f docker-compose.prod.yml restart backend

# Stop application
docker-compose -f docker-compose.prod.yml down

# Start application
docker-compose -f docker-compose.prod.yml up -d

# Update application (after code changes)
git pull origin main
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## System Monitoring
```bash
# Check disk usage
df -h

# Check memory usage
free -h

# Check running processes
htop

# Check Docker system usage
docker system df

# Clean up unused Docker resources
docker system prune -f
```

## Database Management
```bash
# Connect to PostgreSQL database
docker-compose -f docker-compose.prod.yml exec db psql -U postgres -d taskdb

# Backup database
docker-compose -f docker-compose.prod.yml exec db pg_dump -U postgres taskdb > backup_$(date +%Y%m%d_%H%M%S).sql

# View database logs
docker-compose -f docker-compose.prod.yml logs db
```

## Security & Updates
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Update Docker images
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Check open ports
sudo netstat -tlnp

# Check firewall status
sudo ufw status
```

## Troubleshooting
```bash
# If containers fail to start
docker-compose -f docker-compose.prod.yml down
docker system prune -f
docker-compose -f docker-compose.prod.yml up -d

# Check container health
docker-compose -f docker-compose.prod.yml exec backend curl -f http://localhost:5000/tasks
docker-compose -f docker-compose.prod.yml exec frontend curl -f http://localhost

# Rebuild containers
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## Deployment Verification Steps

### Step 1: Check Container Status
```bash
# All containers should show "Up" status
docker-compose -f docker-compose.prod.yml ps

# Expected output:
# NAME              IMAGE                    STATUS
# task-backend      task-manager_backend     Up (healthy)
# task-frontend     task-manager_frontend    Up (healthy)
# taskdb           postgres:15-alpine       Up (healthy)
```

### Step 2: Test Application Endpoints
```bash
# Test database connection
docker-compose -f docker-compose.prod.yml exec db psql -U postgres -d taskdb -c "SELECT 1;"

# Test backend API
curl -X GET http://localhost:5000/tasks

# Test frontend proxy
curl -X GET http://localhost/api/tasks

# Get your public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Your app is available at: http://$PUBLIC_IP"
```

### Step 3: Create a Test Task
```bash
# Create a test task via API
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Welcome Task", "description": "Your app is working!"}'

# Verify the task was created
curl http://localhost/api/tasks
```

## Common Issues & Solutions

### Docker Permission Denied
```bash
# If you get "permission denied" errors with Docker
sudo usermod -aG docker $USER
newgrp docker

# Or logout and SSH back in
exit
ssh -i your-key.pem ubuntu@your-ec2-ip
```

### Docker Compose Version Warning
```bash
# The "version is obsolete" warning can be ignored
# Or update compose files to remove the version field
```

### Container Build Failures
```bash
# Clear Docker cache and rebuild
docker system prune -f
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### Quick Health Check Script
```bash
#!/bin/bash
echo "🔍 Task Manager Health Check"
echo "================================"

# Check containers
echo "📦 Container Status:"
docker-compose -f docker-compose.prod.yml ps

echo -e "\n🔗 API Tests:"
# Test backend directly
echo "Backend API (direct):"
curl -s http://localhost:5000/tasks | head -c 100
echo ""

# Test through nginx proxy
echo "Frontend Proxy:"
curl -s http://localhost/api/tasks | head -c 100
echo ""

# Test database
echo -e "\n💾 Database Test:"
docker-compose -f docker-compose.prod.yml exec db psql -U postgres -d taskdb -c "SELECT 1;" 2>/dev/null && echo "✅ Database OK" || echo "❌ Database Error"

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo -e "\n🌐 Access URLs:"
echo "Frontend: http://$PUBLIC_IP"
echo "API: http://$PUBLIC_IP/api/tasks"
echo "================================"
```

### Emergency Diagnostic Commands
```bash
# 1. Check if Docker daemon is running
sudo systemctl status docker

# 2. Check if compose file is valid
docker-compose -f docker-compose.prod.yml config

# 3. Force remove all containers and restart
docker-compose -f docker-compose.prod.yml down --volumes --remove-orphans
docker system prune -af
docker-compose -f docker-compose.prod.yml up -d --build --force-recreate

# 4. Alternative public IP methods
curl -s ifconfig.me
curl -s http://checkip.amazonaws.com/
dig +short myip.opendns.com @resolver1.opendns.com

# 5. Check if ports are actually open
sudo netstat -tlnp | grep :5000
sudo netstat -tlnp | grep :80

# 6. Test internal container networking
docker network ls
docker-compose -f docker-compose.prod.yml exec backend ping db
```

### Container Restart Procedure
```bash
#!/bin/bash
echo "🔄 Restarting Task Manager Application"

# Stop all services
docker-compose -f docker-compose.prod.yml down --remove-orphans

# Clean Docker system
docker system prune -f

# Rebuild and start
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Wait for services
echo "⏳ Waiting for services to start..."
sleep 45

# Check status
docker-compose -f docker-compose.prod.yml ps

# Test connectivity
echo "🧪 Testing connectivity..."
sleep 10
curl -s http://localhost:5000/tasks && echo "✅ Backend OK" || echo "❌ Backend Failed"
curl -s http://localhost/api/tasks && echo "✅ Proxy OK" || echo "❌ Proxy Failed"

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s http://checkip.amazonaws.com/ 2>/dev/null)
echo "🌐 Public access: http://$PUBLIC_IP"
```
