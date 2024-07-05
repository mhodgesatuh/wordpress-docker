#!/bin/bash

# build.sh - provide sensitive info to docker compose

set_env_var() {
    local var_name=$1
    local var_value

    read -e -p "Enter ${var_name}: " -r var_value
    if [ -z "${var_value}" ]; then
        echo "${var_name} cannot be blank. Exiting..."
        exit 1
    fi

    export "${var_name}"="${var_value}"
}

echo "Be sure to save the information provided here somewhere secure."
echo "Info for the WordPress stack:"
set_env_var "MYSQL_ADMIN_USERNAME"
set_env_var "MYSQL_ADMIN_PASSWORD"
set_env_var "MYSQL_ROOT_PASSWORD"
set_env_var "WP_DATABASE_NAME"
set_env_var "WP_DB_USERNAME"
set_env_var "WP_DB_PASSWORD"

echo "Info for initializing WordPress:"
set_env_var "WP_SITE_TITLE"
set_env_var "WP_SITE_ADMIN_USERNAME"
set_env_var "WP_SITE_ADMIN_PASSWORD"
set_env_var "WP_SITE_ADMIN_EMAIL"

docker-compose up -d
