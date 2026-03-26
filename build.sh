#!/bin/bash

# build.sh - non-interactive Docker Compose startup
# This script reads environment variables from .env file and starts the stack

set -e  # Exit on any error

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found in current directory."
    echo "Please create a .env file with the required environment variables."
    exit 1
fi

# Load environment variables from .env file
export $(cat .env | grep -v '^#' | xargs)

# Validate that all required variables are set
required_vars=(
    "MYSQL_ADMIN_USERNAME"
    "MYSQL_ADMIN_PASSWORD"
    "MYSQL_ROOT_PASSWORD"
    "WORDPRESS_DB_NAME"
    "WORDPRESS_DB_USER"
    "WORDPRESS_DB_PASSWORD"
    "WP_SITE_TITLE"
    "WP_SITE_ADMIN_USERNAME"
    "WP_SITE_ADMIN_PASSWORD"
    "WP_SITE_ADMIN_EMAIL"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo "Error: The following required environment variables are missing in .env:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

echo "Starting WordPress Docker stack with environment from .env..."
docker-compose up -d

echo "✓ Docker stack started successfully"
echo "WordPress will be available at: http://localhost:8080"
echo "phpMyAdmin will be available at: http://localhost:8081"

