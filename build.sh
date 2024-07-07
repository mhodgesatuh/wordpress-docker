#!/bin/bash

# build.sh - provide sensitive info to docker compose

set_env_var() {
    local var_name=$1
    local default_value=$2
    local var_value

    if [ -n "$default_value" ]; then
        read -e -p "Enter ${var_name} [${default_value}]: " -r var_value
        var_value=${var_value:-$default_value}
    else
        read -e -p "Enter ${var_name}: " -r var_value
    fi

    if [ -z "${var_value}" ]; then
        echo "${var_name} cannot be blank. Exiting..."
        exit 1
    fi

    export "${var_name}"="${var_value}"
}

echo "Be sure to save the information provided here somewhere secure."
echo "Info for the WordPress stack:"
set_env_var "MYSQL_ADMIN_USERNAME" "${1}"
set_env_var "MYSQL_ADMIN_PASSWORD" "${2}"
set_env_var "MYSQL_ROOT_PASSWORD" "${3}"
set_env_var "WORDPRESS_DB_NAME" "${4}"
set_env_var "WORDPRESS_DB_USER" "${5}"
set_env_var "WORDPRESS_DB_PASSWORD" "${6}"

echo "Info for initializing WordPress:"
set_env_var "WP_SITE_TITLE" "${7}"
set_env_var "WP_SITE_ADMIN_USERNAME" "${8}"
set_env_var "WP_SITE_ADMIN_PASSWORD" "${9}"
set_env_var "WP_SITE_ADMIN_EMAIL" "${10}"

docker-compose up -d
