FROM php:7-apache

RUN apt-get update && apt-get install -y git unzip libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr
RUN docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql

RUN sed -i 's#^DocumentRoot /var/www/html$#DocumentRoot /var/www/html/web#g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN { \
    echo 'upload_max_filesize=256M'; \
    echo 'post_max_size=256M'; \
} > /usr/local/etc/php/conf.d/upload-size.ini

RUN echo 'max_execution_time=300' > /usr/local/etc/php/conf.d/execution-time.ini

ADD https://getcomposer.org/download/1.0.0/composer.phar /usr/bin/composer.phar
RUN chmod +x /usr/bin/composer.phar

ENV EDUSOHO_VERSION 6.16.0
WORKDIR /var/www/html

# vcs version only ADD https://github.com/EduSoho/EduSoho/archive/v${EDUSOHO_VERSION}.tar.gz /tmp/edusoho.tar.gz
#COPY edusoho-${EDUSOHO_VERSION}.tar.gz /tmp/
ADD http://download.edusoho.com/edusoho-6.16.0.tar.gz /tmp/

RUN tar -xf /tmp/edusoho-${EDUSOHO_VERSION}.tar.gz --strip-components=1
# vcs version only RUN composer.phar install --no-dev --prefer-dist --no-scripts
# vcs version only RUN cp app/config/parameters.yml.dist app/config/parameters.yml
# vcs version only RUN mkdir app/cache
# vcs version only RUN mkdir app/logs

RUN { \
    #chown www-data:www-data app/config/parameters.yml \
    chmod 777 app/config/parameters.yml; \
    chown -R www-data:www-data app/data; \
    chown -R www-data:www-data app/data/udisk; \
    chown -R www-data:www-data app/data/private_files; \
    chown -R www-data:www-data web/files; \
    chown -R www-data:www-data web/install; \
    chown -R www-data:www-data app/cache; \
    chown -R www-data:www-data app/logs; \
}
