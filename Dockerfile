# Dockerfile - Install and set up Wordpress

FROM wordpress:latest

COPY wordpress.conf /etc/httpd/conf.d/wordpress.conf
COPY init.sh /init.sh

RUN apt-get update && \
    apt-get install -y libxml2-dev docker-php-ext-install soap default-mysql-client && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    chmod +x /init.sh && \
    mkdir /var/www/.wp-cli/ && \
    sudo chown -R www-data:www-data /var/www/.wp-cli/

ENTRYPOINT ["/init.sh"]
