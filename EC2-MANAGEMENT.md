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
