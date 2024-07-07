#!/bin/bash

# init-sh - initialize WordPress if needed before starting it

# Initialize a counter for timeout (e.g., 5 minutes)
timeout=30  # 'n' attempts with 5 seconds sleep
until mysqladmin ping -h db -u root --password="${MYSQL_ROOT_PASSWORD}" --silent; do
  if [ $timeout -le 0 ]; then
    echo "Timed out waiting for database to be ready."
    echo "Skipping WordPress setup and starting Apache directly."
    exec apache2-foreground
  fi
  echo 'Waiting for mysql...'
  sleep 5
  ((timeout--))
done

# Change to WordPress directory.
cd /usr/src/wordpress

# Create wp-config.php if it does not exist
if [ ! -f wp-config.php ]; then
  echo "Creating wp-config.php..."

  wp config create \
    --dbhost="${WORDPRESS_DB_HOST}" \
    --dbname="${WORDPRESS_DB_NAME}" \
    --dbuser="${WORDPRESS_DB_USER}" \
    --dbpass="${WORDPRESS_DB_PASSWORD}" \
    --skip-check \
    --allow-root
fi

# Check if WordPress is already installed.
if ! wp core is-installed --allow-root; then
  echo "Setting up WordPress for the first time..."

  # Run the WordPress installation.
  wp core install --url="http://localhost:8080" \
    --title="${WP_SITE_TITLE}" \
    --admin_user="${WP_SITE_ADMIN_USERNAME}" \
    --admin_password="${WP_SITE_ADMIN_PASSWORD}" \
    --admin_email="${WP_SITE_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  # Additional configuration options.
  wp plugin install classic-editor --activate --allow-root
else
  echo "WordPress is already installed."
fi

# Start the Apache server
exec apache2-foreground
