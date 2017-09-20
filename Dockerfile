FROM fguillot/alpine-nginx-php7

ARG URL_PREFIX=''

RUN mkdir -p /var/www/app/$URL_PREFIX

COPY . /var/www/app/$URL_PREFIX

COPY docker/kanboard/config.php /var/www/app/$URL_PREFIX/config.php
COPY docker/crontab/cronjob.alpine /var/spool/cron/crontabs/nginx
COPY docker/services.d/cron /etc/services.d/cron
COPY docker/php/env.conf /etc/php7/php-fpm.d/env.conf

RUN cd /var/www/app/$URL_PREFIX && composer --prefer-dist --no-dev --optimize-autoloader --quiet install
RUN chown -R nginx:nginx /var/www/app/$URL_PREFIX/data /var/www/app/$URL_PREFIX/plugins

RUN if [ ! -z "$URL_PREFIX" ]; then sed -i -r "s|try_files(.*)/index.php|try_files\1/$URL_PREFIX/index.php|" /etc/nginx/nginx.conf; fi
RUN if [ ! -z "$URL_PREFIX" ]; then sed -i -r "s|location(\s+)/|location\1/$URL_PREFIX|" /etc/nginx/nginx.conf; fi

VOLUME /var/www/app/$URL_PREFIX/data
VOLUME /var/www/app/$URL_PREFIX/plugins
