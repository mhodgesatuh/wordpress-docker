FROM wordpress:latest

# Install SOAP extension
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    && docker-php-ext-install soap
