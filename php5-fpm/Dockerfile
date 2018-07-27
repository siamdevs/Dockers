FROM php:5-fpm-alpine
## Build Python 3.7
COPY pyj2cliInstaller.sh pyj2cliInstaller.sh
RUN /bin/sh pyj2cliInstaller.sh

#RUN wget -O pyj2cliInstaller.sh "https://raw.githubusercontent.com/siamdevs/Dockers/master/pyj2cliInstaller.sh?c=26972a2" \
#    && /bin/sh pyj2cliInstaller.sh \
#    && rm -f pyj2cliInstaller.sh 


COPY php.ini.j2 /var/templates/php.ini.j2

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

##ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD ["php-fpm"]