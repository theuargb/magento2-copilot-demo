# Magento 2 Community Edition Demo

This repository contains a fresh installation of **Magento 2.4.8-p3 Community Edition**.

## Installation Details

- **Version**: 2.4.8-p3 (Latest Community Edition as of February 2026)
- **PHP Version**: 8.3.6
- **Composer Version**: 2.9.5

## Project Structure

This is a standard Magento 2 Community Edition installation with the following key directories:

- `app/` - Application code including modules, themes, and configuration
- `bin/` - Magento CLI tools
- `dev/` - Development tools and tests
- `lib/` - Magento libraries
- `pub/` - Publicly accessible files (document root)
- `setup/` - Installation and upgrade scripts
- `var/` - Temporary files, cache, logs
- `vendor/` - Third-party dependencies (managed by Composer)

## Next Steps

To complete the Magento installation, you'll need to:

1. **Configure Database**: Set up MySQL/MariaDB database
2. **Run Installation**: Use the Magento CLI to complete setup:
   ```bash
   bin/magento setup:install \
     --base-url=http://your-domain.com/ \
     --db-host=localhost \
     --db-name=magento \
     --db-user=magento \
     --db-password=your-password \
     --admin-firstname=Admin \
     --admin-lastname=User \
     --admin-email=admin@example.com \
     --admin-user=admin \
     --admin-password=your-admin-password \
     --language=en_US \
     --currency=USD \
     --timezone=America/Chicago \
     --use-rewrites=1
   ```
3. **Configure Web Server**: Point document root to `pub/` directory
4. **Set File Permissions**: Ensure proper permissions for var/, generated/, pub/static/

## Requirements

Magento 2.4.8 requires:
- PHP 8.2 or 8.3
- MySQL 8.0 or MariaDB 10.6
- Elasticsearch 8.x or OpenSearch 2.x
- Composer 2.x
- Web server (Apache 2.4 or Nginx 1.x)

For complete system requirements, see: https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/system-requirements.html

## Documentation

- [Official Magento 2 Documentation](https://experienceleague.adobe.com/docs/commerce.html)
- [Installation Guide](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/overview.html)
- [Developer Documentation](https://developer.adobe.com/commerce/docs/)

## License

Magento 2 Community Edition is licensed under OSL-3.0 and AFL-3.0. See LICENSE.txt for details.