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
  echo 'waiting for mysql...'
  sleep 5
  ((timeout--))
done

# Change to WordPress directory.
cd /usr/src/wordpress

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
