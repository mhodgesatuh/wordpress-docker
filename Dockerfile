# Dockerfile - Install Wordpress

FROM wordpress:latest

# Install SOAP extension.
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    && docker-php-ext-install soap

# Install MySQL client.
RUN apt-get install -y default-mysql-client

# Install WP-CLI.
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Add the initialization script.
COPY init.sh /init.sh
RUN chmod +x /init.sh

# Set entrypoint to the script.
ENTRYPOINT ["/init.sh"]
