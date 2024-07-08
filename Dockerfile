# Use the official WordPress image as the base
FROM wordpress:latest

# Install necessary extensions and MySQL client
RUN apt-get update && \
    apt-get install -y libxml2-dev default-mysql-client && \
    docker-php-ext-install soap

# Copy the local virtual host configuration file to the Apache sites-available directory
COPY wordpress.conf /etc/apache2/sites-available/wordpress.conf

# COPY loctions for certificates to be used by Apache.
# ----
# SSL Certificate: the public certificate provided to clients to establish an
# encrypted connection:
#   /etc/pki/tls/certs/your_domain.crt
# Private Key: the private key associated with the SSL certificate:
#   /etc/pki/tls/private/your_domain.key
# CA Bundle: the file containing the Certificate Authority (CA) certificates
# used to establish a chain of trust:
#   /etc/pki/tls/certs/ca-bundle.crt
# WARNING: ensure Apache can read them.

# Enable the new virtual host, disable the default virtual host, and add the
# ServerName directive
RUN a2ensite wordpress.conf && \
    a2dissite 000-default.conf && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Add the initialization script
COPY init.sh /init.sh
RUN chmod +x /init.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/log/apache2/ && \
    chown -R www-data:www-data /var/log/apache2/ && \
    mkdir /var/www/.wp-cli/ && \
    chown -R www-data:www-data /var/www/.wp-cli/

# Set entrypoint to the script
ENTRYPOINT ["/init.sh"]
