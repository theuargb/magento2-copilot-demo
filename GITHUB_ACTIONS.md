# GitHub Actions for Magento 2 Deployment

This repository includes two GitHub Actions workflows for automated deployment of Magento 2:

1. **Initial Installation** (`install.yml`) - For first-time setup
2. **Continuous Deployment** (`deploy.yml`) - For subsequent updates

## ⚠️ SECURITY WARNING

**This configuration is set up for DEMO/DEVELOPMENT purposes only!**

The workflows include a hardcoded default password for quick demonstration. This is **NOT** secure and should **NEVER** be used in production environments.

**For Production Use:**
1. **NEVER** commit passwords or credentials to your repository
2. Set `SSH_PASSWORD` as a GitHub Secret (Settings → Secrets and variables → Actions)
3. Consider using SSH key-based authentication instead of passwords
4. Rotate credentials immediately if they are exposed
5. Use proper security practices including firewalls, fail2ban, and strong passwords

## Prerequisites

### 1. SSH Access Setup

The workflows support password-based SSH authentication for quick setup and demo purposes.

**For Production:** It's recommended to use SSH key-based authentication instead.

#### Option A: Password Authentication (Current Setup - Demo/Development)

The workflows are configured to use password authentication by default:
- Default server: `89.167.21.190`
- Default password: `rkJTMk3KX4Hk`

For better security, you can override the password using GitHub Secrets (see below).

#### Option B: SSH Key Authentication (Recommended for Production)

Generate SSH Key (on your local machine):
```bash
ssh-keygen -t ed25519 -C "github-actions@magento-deploy" -f ~/.ssh/github_actions_magento
```

Add Public Key to Server:
```bash
ssh-copy-id -i ~/.ssh/github_actions_magento.pub root@89.167.21.190
```

Or manually:
```bash
ssh root@89.167.21.190
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "YOUR_PUBLIC_KEY_CONTENT" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Then modify the workflows to use SSH keys instead of password authentication.

### 2. Configure GitHub Secrets

Go to your repository on GitHub: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

Add the following secrets:

#### Optional Secrets (for overriding defaults):

| Secret Name | Description | Default Value |
|-------------|-------------|---------------|
| `SSH_PASSWORD` | SSH password for server access | `rkJTMk3KX4Hk` |
| `SERVER_IP` | Server IP address (optional, can use workflow input) | `89.167.21.190` |

#### Optional Secrets (if you want to override defaults):

| Secret Name | Description | Default Value |
|-------------|-------------|---------------|
| `DB_NAME` | Database name | `magento2` |
| `DB_USER` | Database user | `magento2` |
| `DB_PASSWORD` | Database password | `magento2` |
| `ADMIN_FIRSTNAME` | Admin first name | `Admin` |
| `ADMIN_LASTNAME` | Admin last name | `User` |
| `ADMIN_EMAIL` | Admin email | `admin@magento.local` |
| `ADMIN_USER` | Admin username | `admin` |
| `ADMIN_PASSWORD` | Admin password | `Admin@123456` |

### 3. How to Add SSH_PRIVATE_KEY Secret

1. Display your private key:
   ```bash
   cat ~/.ssh/github_actions_magento
   ```

2. Copy the entire output (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)

3. Go to GitHub → Repository → Settings → Secrets and variables → Actions

4. Click "New repository secret"

5. Name: `SSH_PRIVATE_KEY`

6. Value: Paste the entire private key

7. Click "Add secret"

## Usage

### First-Time Installation

Use this workflow when setting up Magento for the first time on your server.

#### To Run:
1. Go to your repository on GitHub
2. Click on `Actions` tab
3. Select `Initial Magento Installation` workflow
4. Click `Run workflow`
5. Fill in the inputs:
   - **Server IP Address**: Your server IP (default: `89.167.21.190`)
   - **Base URL**: Your store URL (default: `http://89.167.21.190`)
6. Click `Run workflow`

#### What It Does:
- ✅ Installs Docker and Docker Compose (if not present)
- ✅ Copies code to server
- ✅ Starts all Docker containers (Web, Database, Elasticsearch, Redis)
- ✅ Installs Composer dependencies
- ✅ Runs Magento installation
- ✅ Configures Redis caching
- ✅ Deploys static content
- ✅ Compiles DI
- ✅ Enables production mode
- ✅ Reindexes data

**Time**: ~15-20 minutes

### Subsequent Deployments

This workflow automatically deploys updates when you push to the `main` or `master` branch.

#### Automatic Trigger:
```bash
git add .
git commit -m "Update feature X"
git push origin main
```

The deployment workflow will automatically run!

#### Manual Trigger:
1. Go to your repository on GitHub
2. Click on `Actions` tab
3. Select `Deploy Magento Updates` workflow
4. Click `Run workflow`
5. Fill in the inputs:
   - **Server IP Address**: Your server IP
   - **Skip static content deployment**: Set to `true` to skip static content (faster)
   - **Enable maintenance mode**: Set to `true` to enable maintenance during deployment
6. Click `Run workflow`

#### What It Does:
- ✅ Creates backup before deployment
- ✅ Enables maintenance mode (optional)
- ✅ Syncs code to server
- ✅ Updates Composer dependencies
- ✅ Runs Magento upgrade
- ✅ Compiles DI
- ✅ Deploys static content (optional)
- ✅ Flushes cache
- ✅ Reindexes data
- ✅ Disables maintenance mode

**Time**: ~5-10 minutes

## Workflow Features

### Maintenance Mode
The deployment workflow automatically enables maintenance mode during deployment to prevent customer-facing errors. It's disabled automatically after deployment completes (even if deployment fails).

### Automatic Backups
Before each deployment, the workflow creates a backup of your database and media files using the `backup.sh` script.

### Smart File Syncing
The workflows use `rsync` to efficiently sync only changed files, excluding:
- `.git` directory
- `vendor` (reinstalled via Composer)
- `node_modules`
- `var`, `generated`, `pub/static` (regenerated)

### Error Handling
- If deployment fails, maintenance mode is automatically disabled
- Backups are created before deployment
- Clear error messages in workflow logs

## Monitoring Deployments

### View Deployment Status:
1. Go to `Actions` tab in your repository
2. Click on the running or completed workflow
3. View detailed logs for each step

### Check Deployment on Server:
```bash
ssh root@89.167.21.190
cd /opt/magento2
./magento.sh status    # Check container status
./magento.sh logs      # View logs
```

## Troubleshooting

### SSH Connection Failed
**Problem**: Workflow fails with "Permission denied" or "Connection refused"

**Solutions**:
1. Verify SSH key is added to server:
   ```bash
   ssh -i ~/.ssh/github_actions_magento root@89.167.21.190
   ```
2. Check `SSH_PRIVATE_KEY` secret is correctly set in GitHub
3. Ensure server allows SSH on port 22
4. Verify firewall rules allow GitHub Actions IP ranges

### Deployment Timeout
**Problem**: Workflow takes too long or times out

**Solutions**:
1. Use `skip_static_deploy: true` for faster deployments
2. Increase GitHub Actions timeout in workflow file
3. Check server resources (CPU, RAM, disk space)

### Maintenance Mode Stuck
**Problem**: Site still shows maintenance mode after deployment

**Solution**:
```bash
ssh root@89.167.21.190
cd /opt/magento2
./magento.sh maintenance off
```

### Cache Issues After Deployment
**Problem**: Changes not visible after deployment

**Solution**:
```bash
ssh root@89.167.21.190
cd /opt/magento2
./magento.sh cache-flush
./magento.sh reindex
```

## Advanced Configuration

### Custom Deployment Script

Create `.github/workflows/custom-deploy.yml`:
```yaml
name: Custom Deployment

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install sshpass
        run: |
          sudo apt-get update
          sudo apt-get install -y sshpass
      
      - name: Custom deployment steps
        env:
          SSH_PASSWORD: ${{ secrets.SSH_PASSWORD || 'rkJTMk3KX4Hk' }}
        run: |
          sshpass -p "$SSH_PASSWORD" ssh root@${{ secrets.SERVER_IP }} << 'EOF'
            cd /opt/magento2
            # Your custom commands here
          EOF
```

### Deploy to Multiple Environments

Add environment-specific secrets:
- `STAGING_SSH_PRIVATE_KEY` / `STAGING_SERVER_IP`
- `PRODUCTION_SSH_PRIVATE_KEY` / `PRODUCTION_SERVER_IP`

Modify workflows to use environment-specific secrets.

### Slack/Discord Notifications

Add notification steps to workflows:
```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Security Best Practices

1. **Never commit secrets** - Always use GitHub Secrets
2. **Use dedicated SSH key** - Create a separate key just for deployments
3. **Limit SSH key permissions** - Use key with restricted permissions if possible
4. **Rotate credentials** - Regularly update passwords and keys
5. **Enable 2FA** - Enable two-factor authentication on GitHub
6. **Review access logs** - Monitor server access logs regularly
7. **Use HTTPS** - Set up SSL/TLS for production

## Workflow Files Location

- Initial installation: `.github/workflows/install.yml`
- Continuous deployment: `.github/workflows/deploy.yml`

## Testing Workflows

### Test Installation (Development):
Create a test server and run the installation workflow to verify it works before running on production.

### Test Deployment:
1. Create a test branch
2. Make small changes
3. Run deployment workflow manually
4. Verify changes on server

## Getting Help

If you encounter issues:
1. Check workflow logs in GitHub Actions tab
2. Check server logs: `./magento.sh logs`
3. Review documentation: `DEPLOYMENT.md`, `INSTALL.md`
4. Check Magento logs: `/opt/magento2/var/log/`

## Summary

- **Initial Setup**: Run `Initial Magento Installation` workflow once
- **Updates**: Push to main branch, deployment happens automatically
- **Manual Deploy**: Use `Deploy Magento Updates` workflow when needed
- **Monitor**: Check Actions tab for deployment status
- **Rollback**: Use backups created before each deployment if needed

---

**Quick Start Checklist:**
- [ ] Generate SSH key pair
- [ ] Add public key to server
- [ ] Add `SSH_PRIVATE_KEY` secret to GitHub
- [ ] (Optional) Add other secrets for custom configuration
- [ ] Run `Initial Magento Installation` workflow
- [ ] Test deployment by pushing a change
- [ ] Set up backup schedule if not already done

**That's it!** Your Magento 2 shop now has automated deployment! 🚀
