FROM php:5-fpm-alpine

LABEL MAINTAINER="Parinya Chaipetch <parinya.siamdevs@gmail.com>"

RUN wget -O pyj2cliInstaller.sh "https://raw.githubusercontent.com/siamdevs/Dockers/master/bootstrap/get-python2.7.alpine?c=1005132" \
    && /bin/sh pyj2cliInstaller.sh \
    && rm -f pyj2cliInstaller.sh 

RUN mkdir -p /var/templates
RUN wget -O /var/templates/php.ini.j2 "https://raw.githubusercontent.com/siamdevs/Dockers/master/templates/php.ini.j2?c=1005132" 

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD ["php-fpm"]