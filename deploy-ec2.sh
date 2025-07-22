#!/bin/bash

# EC2 Deployment Script for Task Manager Application
# Run this script on your EC2 instance to deploy the application

set -e

echo "Starting Task Manager Application Deployment on EC2"

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker installed successfully"
else
    echo "Docker is already installed"
fi

# Install Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully"
else
    echo "Docker Compose is already installed"
fi

# Install Git if not present
if ! command -v git &> /dev/null; then
    echo "Installing Git..."
    sudo apt-get install -y git
    echo "Git installed successfully"
fi

# Clone or update the repository
REPO_URL="https://github.com/Pritee-c/task-manager-flask-docker.git"
APP_DIR="/home/ubuntu/task-manager"

if [ -d "$APP_DIR" ]; then
    echo "Updating existing repository..."
    cd $APP_DIR
    git pull origin main
else
    echo "Cloning repository..."
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# Create environment file
if [ ! -f ".env" ]; then
    echo "Creating environment file..."
    cp .env.example .env
    
    # Generate a secure password
    SECURE_PASSWORD=$(openssl rand -base64 32)
    sed -i "s/your_secure_password_here/$SECURE_PASSWORD/g" .env
    
    echo "Environment file created with secure password"
    echo "Environment file location: $APP_DIR/.env"
fi

# Create necessary directories
mkdir -p ssl logs

# Set proper permissions
sudo chown -R $USER:$USER $APP_DIR

# Build and start the application
echo "Building and starting the application..."
docker-compose -f docker-compose.prod.yml down --remove-orphans
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d

# Wait for services to be healthy
echo " Waiting for services to be ready..."
sleep 30

# Check service status
echo " Checking service status..."
docker-compose -f docker-compose.prod.yml ps

# Show logs
echo "Recent application logs:"
docker-compose -f docker-compose.prod.yml logs --tail=20

# Get EC2 instance public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "Deployment completed successfully!"
echo ""
echo "Your application is now running at:"
echo "   HTTP:  http://$PUBLIC_IP"
echo "   Local: http://localhost"
echo ""
echo "🔧 Management commands:"
echo "   View logs:    docker-compose -f docker-compose.prod.yml logs -f"
echo "   Stop app:     docker-compose -f docker-compose.prod.yml down"
echo "   Restart app:  docker-compose -f docker-compose.prod.yml restart"
echo "   Update app:   git pull && docker-compose -f docker-compose.prod.yml up -d --build"
echo ""
echo "Application directory: $APP_DIR"
echo "Environment file: $APP_DIR/.env"
echo ""
echo "Security Notes:"
echo "   - Change the default database password in .env file"
echo "   - Consider setting up SSL certificates for HTTPS"
echo "   - Configure EC2 security groups to allow HTTP/HTTPS traffic"
