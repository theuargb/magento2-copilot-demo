# Deployment Guide for Hetzner Server (89.167.21.190)

This guide will help you deploy the Magento 2 shop on your Hetzner server.

## Server Information
- **IP Address**: 89.167.21.190
- **User**: root
- **Access URL**: http://89.167.21.190

## Prerequisites

Your Hetzner server should have:
- Ubuntu 20.04 or later (or Debian 10+)
- At least 4GB RAM (8GB recommended)
- At least 20GB free disk space
- Port 80 open for HTTP traffic

## Deployment Steps

### Option 1: Automated Deployment (Recommended)

1. **Connect to your server via SSH:**
   ```bash
   ssh root@89.167.21.190
   ```
   Password: `rkJTMk3KX4Hk`

2. **Install Git (if not already installed):**
   ```bash
   apt update
   apt install -y git
   ```

3. **Clone the repository:**
   ```bash
   cd /opt
   git clone https://github.com/theuargb/magento2-copilot-demo.git magento2
   cd magento2
   ```

4. **Run the deployment script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   This script will:
   - Install Docker and Docker Compose (if not present)
   - Start all required services (Web server, MariaDB, Elasticsearch, Redis)
   - Install Magento with all dependencies
   - Configure Magento for your server IP
   - Set up caching and optimization
   - Deploy the shop in production mode

5. **Wait for completion:**
   The installation process takes approximately 10-15 minutes.

6. **Access your Magento shop:**
   - **Store**: http://89.167.21.190
   - **Admin Panel**: http://89.167.21.190/admin
   
   **Admin Credentials:**
   - Username: `admin`
   - Password: `Admin@123456` (Please change this after first login!)

### Option 2: Manual Deployment

If you prefer to install manually or need to customize the installation:

1. **Connect to your server:**
   ```bash
   ssh root@89.167.21.190
   ```

2. **Install Docker:**
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   systemctl enable docker
   systemctl start docker
   ```

3. **Install Docker Compose:**
   ```bash
   curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   ```

4. **Clone repository:**
   ```bash
   cd /opt
   git clone https://github.com/theuargb/magento2-copilot-demo.git magento2
   cd magento2
   ```

5. **Start Docker containers:**
   ```bash
   docker-compose up -d
   ```

6. **Wait for services (about 30 seconds):**
   ```bash
   docker-compose logs -f
   # Press Ctrl+C when you see services are ready
   ```

7. **Install Composer dependencies:**
   ```bash
   docker-compose exec web composer install
   ```

8. **Install Magento:**
   ```bash
   docker-compose exec web bin/magento setup:install \
       --base-url=http://89.167.21.190/ \
       --db-host=db \
       --db-name=magento2 \
       --db-user=magento2 \
       --db-password=magento2 \
       --admin-firstname=Admin \
       --admin-lastname=User \
       --admin-email=admin@magento.local \
       --admin-user=admin \
       --admin-password=Admin@123456 \
       --language=en_US \
       --currency=USD \
       --timezone=America/Chicago \
       --use-rewrites=1 \
       --search-engine=elasticsearch8 \
       --elasticsearch-host=elasticsearch \
       --elasticsearch-port=9200
   ```

9. **Deploy static content:**
   ```bash
   docker-compose exec web bin/magento setup:static-content:deploy -f
   docker-compose exec web bin/magento setup:di:compile
   docker-compose exec web bin/magento indexer:reindex
   docker-compose exec web bin/magento cache:flush
   ```

10. **Set permissions:**
    ```bash
    docker-compose exec web chmod -R 777 var/ generated/ pub/static/ pub/media/
    ```

## Post-Installation

### Change Admin Password
1. Log in to admin panel at http://89.167.21.190/admin
2. Go to System → Permissions → All Users
3. Click on 'admin' user
4. Change the password to something secure

### Configure Store Settings
1. Go to Stores → Configuration → General → Web
2. Verify the Base URLs are correct
3. Configure your store name, logo, and other settings

### Install Sample Data (Optional)
If you want to test with sample products:
```bash
docker-compose exec web bin/magento sampledata:deploy
docker-compose exec web bin/magento setup:upgrade
docker-compose exec web bin/magento cache:flush
```

## Useful Commands

### View logs:
```bash
docker-compose logs -f web
docker-compose logs -f db
```

### Restart services:
```bash
docker-compose restart
```

### Stop all services:
```bash
docker-compose down
```

### Start services again:
```bash
docker-compose up -d
```

### Clear Magento cache:
```bash
docker-compose exec web bin/magento cache:flush
```

### Reindex:
```bash
docker-compose exec web bin/magento indexer:reindex
```

### Enter web container shell:
```bash
docker-compose exec web bash
```

## Troubleshooting

### Port 80 is already in use
If you have Apache or Nginx already running:
```bash
systemctl stop apache2
systemctl disable apache2
# or
systemctl stop nginx
systemctl disable nginx
```

### Services won't start
Check if all ports are available:
```bash
netstat -tulpn | grep -E ':(80|3306|9200|6379)'
```

### Can't access the website
1. Check if Docker containers are running:
   ```bash
   docker-compose ps
   ```

2. Check if firewall allows port 80:
   ```bash
   ufw allow 80/tcp
   ufw status
   ```

3. Check web server logs:
   ```bash
   docker-compose logs web
   ```

### Database connection issues
```bash
docker-compose restart db
docker-compose exec db mysql -umagento2 -pmagento2 -e "SHOW DATABASES;"
```

## Security Recommendations

1. **Change default passwords** immediately after installation
2. **Set up HTTPS** using Let's Encrypt (requires domain name)
3. **Configure firewall** to only allow necessary ports
4. **Keep Magento updated** regularly
5. **Enable two-factor authentication** for admin users
6. **Regular backups** of database and media files

## Support

For Magento documentation, visit:
- https://experienceleague.adobe.com/docs/commerce.html
- https://devdocs.magento.com/

For Docker issues:
- https://docs.docker.com/

## Notes

- This setup uses MariaDB 10.6, Elasticsearch 8.11, and Redis for caching
- PHP 8.3 is configured with appropriate settings for Magento 2.4.8
- The setup is optimized for production use with caching enabled
- All data is persisted in Docker volumes
