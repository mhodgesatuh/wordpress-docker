#!/bin/bash

# init.sh - Non-interactive WordPress initialization script


# Function to log messages with timestamps
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

# Function to wait for database with timeout
wait_for_db() {
    local timeout=60  # 60 attempts with 5 seconds sleep = 5 minutes max
    local host="${1:-db}"
    local user="${2:-root}"
    local password="${3}"

    log "Waiting for database at $host to be ready..."

    until mysqladmin ping -h "$host" -u "$user" --password="$password" --ssl=0 --silent 2>/dev/null; do
        if [ $timeout -le 0 ]; then
            log "ERROR: Timed out waiting for database to be ready after 5 minutes."
            return 1
        fi
        echo "  Retrying in 5 seconds... ($timeout attempts remaining)"
        sleep 5
        ((timeout--))
    done

    log "✓ Database is ready"
    return 0
}

# Wait for database to be ready
if ! wait_for_db "${WORDPRESS_DB_HOST%:*}" "${WORDPRESS_DB_USER}" "${WORDPRESS_DB_PASSWORD}"; then
    log "ERROR: Could not connect to database. Attempting to start Apache anyway..."
    exec apache2-foreground
fi

# Change to WordPress directory
cd /usr/src/wordpress
log "Working directory: $(pwd)"

# Validate required environment variables
required_vars=(
    "WORDPRESS_DB_HOST"
    "WORDPRESS_DB_NAME"
    "WORDPRESS_DB_USER"
    "WORDPRESS_DB_PASSWORD"
    "WP_SITE_TITLE"
    "WP_SITE_ADMIN_USERNAME"
    "WP_SITE_ADMIN_PASSWORD"
    "WP_SITE_ADMIN_EMAIL"
)

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "ERROR: Required environment variable $var is not set"
        exit 1
    fi
done

# Create wp-config.php if it does not exist
if [ ! -f wp-config.php ]; then
    log "Creating wp-config.php..."
    wp config create \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --skip-check \
        --allow-root 2>&1 || {
        log "ERROR: Failed to create wp-config.php"
        exit 1
    }
    log "✓ wp-config.php created"
else
    log "wp-config.php already exists"
fi

# Check if WordPress is already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    log "Installing WordPress..."

    wp core install \
        --url="http://localhost:8080" \
        --title="${WP_SITE_TITLE}" \
        --admin_user="${WP_SITE_ADMIN_USERNAME}" \
        --admin_password="${WP_SITE_ADMIN_PASSWORD}" \
        --admin_email="${WP_SITE_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root 2>&1 || {
        log "ERROR: Failed to install WordPress"
        exit 1
    }

    log "✓ WordPress installation completed"

    # Install and activate classic editor
    log "Installing classic-editor plugin..."
    wp plugin install classic-editor --activate --allow-root 2>&1 || {
        log "WARNING: Could not install classic-editor plugin (non-fatal)"
    }
    log "✓ Setup complete"
else
    log "WordPress is already installed"
fi

log "Starting Apache web server..."
exec apache2-foreground
