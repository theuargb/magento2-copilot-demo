# 🚀 Install Your Magento Shop on Hetzner Server

## Server Information
- **IP**: 89.167.21.190
- **User**: root
- **Password**: rkJTMk3KX4Hk

---

## ⚡ Quick Installation (Recommended)

### Step 1: Connect to Your Server
Open a terminal and run:
```bash
ssh root@89.167.21.190
```
Enter password when prompted: `rkJTMk3KX4Hk`

### Step 2: Run the Automated Installer
Copy and paste this **one command**:
```bash
bash <(curl -s https://raw.githubusercontent.com/theuargb/magento2-copilot-demo/copilot/install-magento-shop/quick-start.sh)
```

That's it! Wait 10-15 minutes for the installation to complete.

---

## ✅ After Installation

Once complete, you can access:

### Your Store
**URL**: http://89.167.21.190
- Browse products
- Add to cart
- Complete checkout

### Admin Panel
**URL**: http://89.167.21.190/admin
- **Username**: `admin`
- **Password**: `Admin@123456`

⚠️ **IMPORTANT**: Change the admin password immediately after first login!

---

## 📋 Alternative: Manual Installation

If you prefer step-by-step control:

1. **Connect to server**:
   ```bash
   ssh root@89.167.21.190
   ```

2. **Install Git** (if needed):
   ```bash
   apt update && apt install -y git
   ```

3. **Clone repository**:
   ```bash
   cd /opt
   git clone https://github.com/theuargb/magento2-copilot-demo.git magento2
   cd magento2
   ```

4. **Run deployment**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

---

## 🛠️ Management Commands

After installation, you can use these commands from `/opt/magento2`:

```bash
./magento.sh start         # Start services
./magento.sh stop          # Stop services
./magento.sh restart       # Restart services
./magento.sh status        # Check status
./magento.sh logs          # View logs
./magento.sh cache-flush   # Clear cache
./magento.sh reindex       # Reindex data
./magento.sh backup        # Create backup
./magento.sh shell         # Open container shell
```

---

## 🔧 Troubleshooting

### Can't Access Website?
```bash
# Check if containers are running
cd /opt/magento2
docker-compose ps

# Check firewall
ufw allow 80/tcp
ufw status
```

### Need to Restart?
```bash
cd /opt/magento2
./magento.sh restart
```

### View Logs?
```bash
cd /opt/magento2
./magento.sh logs
```

---

## 📚 Full Documentation

For detailed information, see:
- [DEPLOYMENT.md](DEPLOYMENT.md) - Complete deployment guide
- [README.md](README.md) - Project information

---

## 🔐 Security Checklist

After installation:
- [ ] Change admin password
- [ ] Update admin email
- [ ] Configure firewall (allow only port 80/443)
- [ ] Set up regular backups (`./magento.sh backup`)
- [ ] Enable HTTPS (if you have a domain name)

---

## 💾 Backup Your Store

Create regular backups:
```bash
cd /opt/magento2
./backup.sh
```

Backups are stored in `/opt/magento2-backups/`

---

## 📞 Need Help?

- **Magento Documentation**: https://experienceleague.adobe.com/docs/commerce.html
- **Docker Documentation**: https://docs.docker.com/
- Check logs: `./magento.sh logs`
- Check container status: `docker-compose ps`

---

## 🎉 What's Included

Your installation includes:
- ✅ Magento 2.4.8-p3 Community Edition
- ✅ PHP 8.3 with optimal settings
- ✅ MariaDB 10.6 database
- ✅ Elasticsearch 8.11 for search
- ✅ Redis for caching
- ✅ Automated setup and configuration
- ✅ Production-ready settings
- ✅ Management scripts
- ✅ Backup scripts

---

**Ready to install?** Just run the quick installation command from Step 2 above! 🚀
