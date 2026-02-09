# GitHub Actions Deployment Workflows

## Visual Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    GITHUB ACTIONS WORKFLOWS                     │
└─────────────────────────────────────────────────────────────────┘

╔═══════════════════════════════════════════════════════════════════╗
║                   1. INITIAL INSTALLATION                         ║
║                  (install.yml - Manual Trigger)                   ║
╚═══════════════════════════════════════════════════════════════════╝

   Trigger: Manual (workflow_dispatch)
      │
      ├─→ [Checkout Code]
      │
      ├─→ [Setup SSH Connection]
      │
      ├─→ [Install Docker & Docker Compose]
      │
      ├─→ [Copy Repository to Server]
      │
      ├─→ [Start Docker Containers]
      │      └─→ Web (PHP 8.3 + Apache)
      │      └─→ MariaDB 10.6
      │      └─→ Elasticsearch 8.11
      │      └─→ Redis
      │
      ├─→ [Install Composer Dependencies]
      │
      ├─→ [Install Magento]
      │      └─→ Database setup
      │      └─→ Admin user creation
      │      └─→ Base configuration
      │
      ├─→ [Configure Redis Caching]
      │
      ├─→ [Deploy Static Content & Compile]
      │
      └─→ [Enable Production Mode]
            │
            ✓ Installation Complete!
              Store: http://89.167.21.190
              Admin: http://89.167.21.190/admin


╔═══════════════════════════════════════════════════════════════════╗
║                   2. CONTINUOUS DEPLOYMENT                        ║
║           (deploy.yml - Auto or Manual Trigger)                   ║
╚═══════════════════════════════════════════════════════════════════╝

   Trigger: Push to main/master OR Manual
      │
      ├─→ [Checkout Code]
      │
      ├─→ [Setup SSH Connection]
      │
      ├─→ [Create Backup] 
      │      └─→ Database dump
      │      └─→ Media files
      │
      ├─→ [Enable Maintenance Mode] ⚠️
      │      └─→ "We're updating, be right back"
      │
      ├─→ [Sync Code to Server]
      │      └─→ rsync (only changed files)
      │
      ├─→ [Update Composer Dependencies]
      │
      ├─→ [Run Magento Upgrade]
      │      └─→ Database migrations
      │      └─→ Schema updates
      │
      ├─→ [Compile DI]
      │
      ├─→ [Deploy Static Content] (optional)
      │
      ├─→ [Set Permissions]
      │
      ├─→ [Flush Cache]
      │
      ├─→ [Reindex]
      │
      └─→ [Disable Maintenance Mode] ✓
            │
            ✓ Deployment Complete!
              Site is live with updates


╔═══════════════════════════════════════════════════════════════════╗
║                      WORKFLOW COMPARISON                          ║
╚═══════════════════════════════════════════════════════════════════╝

┌────────────────────┬──────────────────┬────────────────────────┐
│     Feature        │  Install.yml     │     Deploy.yml         │
├────────────────────┼──────────────────┼────────────────────────┤
│ Trigger            │ Manual only      │ Auto on push or manual │
│ Duration           │ ~15-20 minutes   │ ~5-10 minutes          │
│ Installs Docker    │ Yes              │ No                     │
│ Full Installation  │ Yes              │ No                     │
│ Creates Backup     │ No               │ Yes                    │
│ Maintenance Mode   │ N/A              │ Yes (optional)         │
│ When to Use        │ First time only  │ All updates            │
└────────────────────┴──────────────────┴────────────────────────┘


╔═══════════════════════════════════════════════════════════════════╗
║                    DEPLOYMENT FLOW CHART                          ║
╚═══════════════════════════════════════════════════════════════════╝

                    [New Server]
                         │
                         │ First time?
                         ├─ Yes ──→ Run install.yml
                         │             │
                         │             ✓
                         │             │
                         │        [Server Ready]
                         │             │
                         └─ No ───────┤
                                      │
                         [Make Code Changes]
                                      │
                                git commit
                                git push
                                      │
                              deploy.yml runs
                               automatically
                                      │
                                      ✓
                                      │
                              [Updates Live]


╔═══════════════════════════════════════════════════════════════════╗
║                     REQUIRED SETUP                                ║
╚═══════════════════════════════════════════════════════════════════╝

1. Generate SSH Key
   ├─→ ssh-keygen -t ed25519 -C "github-actions"
   
2. Add Public Key to Server
   ├─→ ssh-copy-id root@89.167.21.190
   
3. Add Private Key to GitHub Secrets
   ├─→ Repository → Settings → Secrets
   └─→ SSH_PRIVATE_KEY = (private key content)

4. Run Initial Installation
   ├─→ Actions → Initial Magento Installation
   └─→ Run workflow

5. Start Developing!
   └─→ Push to main → Auto-deploy ✨


╔═══════════════════════════════════════════════════════════════════╗
║                    MONITORING & CONTROL                           ║
╚═══════════════════════════════════════════════════════════════════╝

GitHub Actions Tab
   └─→ View all workflow runs
   └─→ Check deployment status
   └─→ View detailed logs
   └─→ Re-run failed deployments

SSH to Server
   └─→ cd /opt/magento2
   └─→ ./magento.sh status     # Check containers
   └─→ ./magento.sh logs       # View logs
   └─→ ./magento.sh cache-flush # Clear cache
```

## Quick Links

- 📖 [Complete Documentation](GITHUB_ACTIONS.md)
- 🚀 [Quick Reference](WORKFLOWS.md)
- 💻 [Installation Guide](../INSTALL.md)
- 🔧 [Deployment Guide](../DEPLOYMENT.md)
