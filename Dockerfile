FROM php:7.0-apache
COPY assignment/* /var/www/html/
RUN docker-php-ext-install mysqli
EXPOSE 80
