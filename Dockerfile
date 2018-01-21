FROM php:7.1-apache

# Adding apache2 vhost
ADD ./config/magento.conf /etc/apache2/sites-available/magento2dev.com.conf

# Enabling site in apache2
RUN a2ensite magento2dev.com.conf

# Install System Dependencies
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	software-properties-common \
	python-software-properties \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	libfreetype6-dev \
	libicu-dev \
  	libssl-dev \
	libjpeg62-turbo-dev \
	libmcrypt-dev \
	libpng12-dev \
	libedit-dev \
	libedit2 \
	libxslt1-dev \
	apt-utils \
  	mysql-client \
	git \
	vim \
	wget \
	curl \
	lynx \
	psmisc \
	unzip \
	tar \
	cron \
	bash-completion \
	&& apt-get clean

# Installing Magento 2 specific PHP extensions
RUN docker-php-ext-configure \
  	gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/; \
  	docker-php-ext-install \
  	opcache \
  	gd \
  	bcmath \
  	intl \
  	mbstring \
  	mcrypt \
  	pdo_mysql \
  	soap \
  	xsl \
  	zip

# Adding php.ini
ADD ./config/php.ini /usr/local/etc/php/php.ini

# Installing XDebug
RUN yes | pecl install xdebug && \
	 echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.iniOLD

# Adding XDebug configurations
ADD ./config/custom-xdebug.ini /usr/local/etc/php/conf.d/custom-xdebug.ini

# Installing composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Installing nano
RUN apt-get install -y nano

VOLUME /var/www/html
WORKDIR /var/www/html

# Setting up necessary files/folders permissions
RUN chown -Rf www-data:www-data /var/www/html /var/www/html/.* \
	&& usermod -u 1000 www-data \
	&& chsh -s /bin/bash www-data\
	&& a2enmod rewrite \
	&& a2enmod headers