#!/bin/bash

# reset-db.sh - Reset WordPress database for a fresh start
# This script removes the database volume and recreates it on the next startup.

set -e

echo "=========================================="
echo "WordPress Database Reset Script"
echo "=========================================="
echo ""
echo "WARNING: This will delete all WordPress data!"
echo "Your credentials will be preserved from the .env file"
echo ""
read -p "Are you sure you want to reset the database? (type 'yes' to confirm): " -r confirm

if [ "$confirm" != "yes" ]; then
    echo "Reset cancelled."
    exit 0
fi

echo ""
echo "Stopping services..."
docker compose down

echo "Removing database volume..."
docker volume rm wordpress-docker_db_data

echo "Starting services with fresh database..."
docker compose up -d

echo ""
echo "=========================================="
echo "✓ Database reset complete!"
echo "=========================================="
echo ""
echo "WordPress is initializing..."
echo "Check progress with: docker compose logs -f wordpress"
echo ""
echo "Once ready, access:"
echo "  WordPress: http://localhost:8080"
echo "  phpMyAdmin: http://localhost:8081"
echo ""

