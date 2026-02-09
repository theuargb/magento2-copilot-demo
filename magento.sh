#!/bin/bash

# Magento 2 Management Script
# Provides easy commands for common Magento operations

set -e

show_help() {
    cat << EOF
Magento 2 Management Script

Usage: ./magento.sh [command]

Commands:
    start          Start all Docker containers
    stop           Stop all Docker containers
    restart        Restart all Docker containers
    status         Show status of all containers
    logs           Show logs from all containers
    cache-flush    Flush Magento cache
    cache-clean    Clean Magento cache
    reindex        Run all indexers
    compile        Run DI compilation
    deploy         Deploy static content
    upgrade        Run Magento upgrade
    maintenance    Toggle maintenance mode (on/off)
    backup         Create backup of database and media
    shell          Enter web container shell
    mysql          Enter MySQL console
    permissions    Fix file permissions
    admin-uri      Show admin URI
    version        Show Magento version
    help           Show this help message

Examples:
    ./magento.sh start
    ./magento.sh cache-flush
    ./magento.sh logs
EOF
}

# Check if docker-compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        echo "Error: docker-compose is not installed"
        exit 1
    fi
}

case "$1" in
    start)
        check_docker_compose
        echo "Starting Magento containers..."
        docker-compose up -d
        echo "Containers started!"
        ;;
    
    stop)
        check_docker_compose
        echo "Stopping Magento containers..."
        docker-compose down
        echo "Containers stopped!"
        ;;
    
    restart)
        check_docker_compose
        echo "Restarting Magento containers..."
        docker-compose restart
        echo "Containers restarted!"
        ;;
    
    status)
        check_docker_compose
        docker-compose ps
        ;;
    
    logs)
        check_docker_compose
        docker-compose logs -f --tail=100
        ;;
    
    cache-flush)
        check_docker_compose
        echo "Flushing Magento cache..."
        docker-compose exec web bin/magento cache:flush
        echo "Cache flushed!"
        ;;
    
    cache-clean)
        check_docker_compose
        echo "Cleaning Magento cache..."
        docker-compose exec web bin/magento cache:clean
        echo "Cache cleaned!"
        ;;
    
    reindex)
        check_docker_compose
        echo "Running indexers..."
        docker-compose exec web bin/magento indexer:reindex
        echo "Reindexing complete!"
        ;;
    
    compile)
        check_docker_compose
        echo "Compiling DI..."
        docker-compose exec web bin/magento setup:di:compile
        echo "Compilation complete!"
        ;;
    
    deploy)
        check_docker_compose
        echo "Deploying static content..."
        docker-compose exec web bin/magento setup:static-content:deploy -f
        echo "Deployment complete!"
        ;;
    
    upgrade)
        check_docker_compose
        echo "Running Magento upgrade..."
        docker-compose exec web bin/magento setup:upgrade
        echo "Upgrade complete!"
        ;;
    
    maintenance)
        check_docker_compose
        if [ "$2" == "on" ]; then
            docker-compose exec web bin/magento maintenance:enable
            echo "Maintenance mode enabled"
        elif [ "$2" == "off" ]; then
            docker-compose exec web bin/magento maintenance:disable
            echo "Maintenance mode disabled"
        else
            docker-compose exec web bin/magento maintenance:status
        fi
        ;;
    
    backup)
        check_docker_compose
        ./backup.sh
        ;;
    
    shell)
        check_docker_compose
        docker-compose exec web bash
        ;;
    
    mysql)
        check_docker_compose
        docker-compose exec db mysql -umagento2 -pmagento2 magento2
        ;;
    
    permissions)
        check_docker_compose
        echo "Fixing file permissions..."
        docker-compose exec web chmod -R 777 var/ generated/ pub/static/ pub/media/
        echo "Permissions fixed!"
        ;;
    
    admin-uri)
        check_docker_compose
        docker-compose exec web bin/magento info:adminuri
        ;;
    
    version)
        check_docker_compose
        docker-compose exec web bin/magento --version
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        echo "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
