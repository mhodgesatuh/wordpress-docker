#!/bin/bash

# build.sh - provide sensitive info to docker compose

set_env_var() {
    local var_name=$1
    local def_value=${!var_name}
    local var_value

    if [ -n "${def_value}" ]; then
        read -e -p "Enter ${var_name} [${def_value}]: " -i "${def_value}" -r var_value
    else
        read -e -p "Enter ${var_name}: " -r var_value
    fi
    echo
    if [ -z "${var_value}" ]; then
        echo "${var_name} cannot be blank. Exiting..."
        exit 1
    fi
    export "${var_name}=${var_value}"
}

echo "Be sure to save the information provided here somewhere secure."

set_env_var "MYSQL_USERNAME"
set_env_var "MYSQL_ROOT_PASSWORD"
set_env_var "MYSQL_PASSWORD"
set_env_var "WORDPRESS_DB_PASSWORD"

docker-compose up -d
