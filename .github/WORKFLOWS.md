# GitHub Actions Quick Reference

## Workflows

### 1. Initial Magento Installation
**File**: `.github/workflows/install.yml`
**Trigger**: Manual (workflow_dispatch)
**Purpose**: First-time Magento installation on server

**Steps**:
1. Install Docker & Docker Compose
2. Deploy code to server
3. Start containers
4. Install Magento
5. Configure services
6. Enable production mode

**Duration**: ~15-20 minutes

### 2. Deploy Magento Updates
**File**: `.github/workflows/deploy.yml`
**Trigger**: 
- Automatic: Push to main/master branch
- Manual: workflow_dispatch

**Purpose**: Deploy code updates and run upgrades

**Steps**:
1. Backup database and media
2. Enable maintenance mode
3. Sync code
4. Update dependencies
5. Run Magento upgrade
6. Compile and deploy
7. Flush cache and reindex
8. Disable maintenance mode

**Duration**: ~5-10 minutes

## Required GitHub Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `SSH_PRIVATE_KEY` | ✅ Yes | SSH private key for server access |
| `SERVER_IP` | ⚠️ Optional | Server IP (can use workflow input) |
| `DB_NAME` | ❌ No | Database name (default: magento2) |
| `DB_USER` | ❌ No | Database user (default: magento2) |
| `DB_PASSWORD` | ❌ No | Database password (default: magento2) |
| `ADMIN_FIRSTNAME` | ❌ No | Admin first name (default: Admin) |
| `ADMIN_LASTNAME` | ❌ No | Admin last name (default: User) |
| `ADMIN_EMAIL` | ❌ No | Admin email (default: admin@magento.local) |
| `ADMIN_USER` | ❌ No | Admin username (default: admin) |
| `ADMIN_PASSWORD` | ❌ No | Admin password (default: Admin@123456) |

## How to Run

### Initial Installation
1. GitHub → Repository → Actions
2. Select "Initial Magento Installation"
3. Click "Run workflow"
4. Enter server IP and base URL
5. Click "Run workflow" button

### Deployment (Automatic)
```bash
git add .
git commit -m "Your changes"
git push origin main
```

### Deployment (Manual)
1. GitHub → Repository → Actions
2. Select "Deploy Magento Updates"
3. Click "Run workflow"
4. Configure options (optional)
5. Click "Run workflow" button

## Workflow Inputs

### Initial Installation
- `server_ip`: Server IP address (default: 89.167.21.190)
- `base_url`: Base URL for Magento (default: http://89.167.21.190)

### Deployment
- `server_ip`: Server IP address (default: from secrets or 89.167.21.190)
- `skip_static_deploy`: Skip static content deployment (default: false)
- `maintenance_mode`: Enable maintenance during deploy (default: true)

## Common Commands

### Check Deployment Status
```bash
ssh root@89.167.21.190
cd /opt/magento2
./magento.sh status
```

### View Logs
```bash
./magento.sh logs
```

### Manual Cache Flush
```bash
./magento.sh cache-flush
```

### Disable Maintenance Mode (if stuck)
```bash
./magento.sh maintenance off
```

## Troubleshooting

### Issue: SSH Connection Failed
- Check SSH_PRIVATE_KEY secret is correct
- Verify server allows SSH from GitHub Actions IPs
- Test SSH manually: `ssh -i ~/.ssh/key root@SERVER_IP`

### Issue: Deployment Timeout
- Use `skip_static_deploy: true` for faster deployments
- Check server resources (RAM, CPU, disk)

### Issue: Maintenance Mode Stuck
```bash
ssh root@89.167.21.190
cd /opt/magento2
docker-compose exec web bin/magento maintenance:disable
```

## File Structure
```
.github/
└── workflows/
    ├── install.yml      # Initial installation workflow
    └── deploy.yml       # Deployment workflow
```

## Documentation Links
- [Complete Guide](GITHUB_ACTIONS.md)
- [Installation Guide](INSTALL.md)
- [Deployment Guide](DEPLOYMENT.md)
