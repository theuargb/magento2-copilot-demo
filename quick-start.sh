#!/bin/bash

# Quick Start Script for Magento 2 Deployment
# Run this on your Hetzner server: bash <(curl -s https://raw.githubusercontent.com/theuargb/magento2-copilot-demo/main/quick-start.sh)

set -e

echo "=========================================="
echo "  Magento 2 Quick Deployment"
echo "  Server: 89.167.21.190"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (or use sudo)"
    exit 1
fi

# Install git if not present
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt update
    apt install -y git
fi

# Navigate to /opt and clone repository
echo "Cloning Magento repository..."
cd /opt
if [ -d "magento2" ]; then
    echo "Directory /opt/magento2 already exists."
    read -p "Remove and reinstall? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf magento2
        git clone https://github.com/theuargb/magento2-copilot-demo.git magento2
    else
        echo "Using existing installation..."
    fi
else
    git clone https://github.com/theuargb/magento2-copilot-demo.git magento2
fi

cd magento2

# Run deployment script
echo ""
echo "Starting deployment..."
chmod +x deploy.sh
./deploy.sh

echo ""
echo "=========================================="
echo "  Deployment Complete!"
echo "=========================================="
echo ""
echo "Your Magento shop is ready at:"
echo "  http://89.167.21.190"
echo ""
echo "Admin panel:"
echo "  http://89.167.21.190/admin"
echo "  Username: admin"
echo "  Password: Admin@123456"
echo ""
echo "IMPORTANT: Change the admin password immediately!"
echo ""
