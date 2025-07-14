FROM ubuntu:25.04

ENV DEBIAN_FRONTEND=noninteractive
ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV RAILS_ENV production

RUN apt-get update \
 && apt install -y software-properties-common supervisor postgresql-client sudo wget \
 && add-apt-repository universe -y

# Install https://github.com/kivitendo/kivitendo-ansible/blob/master/main.yml
RUN apt-get update && apt install -y wget tar \ 
    apache2 git libalgorithm-checkdigits-perl libapache2-mod-fcgid libarchive-zip-perl \
    libcam-pdf-perl libcgi-pm-perl libclone-perl libconfig-std-perl libcrypt-pbkdf2-perl \
    libdaemon-generic-perl libdatetime-event-cron-perl libdatetime-perl libdatetime-set-perl \
    libdbd-pg-perl libdbi-perl libemail-address-perl libemail-mime-perl \
    libexception-class-perl libfcgi-perl libfile-copy-recursive-perl libfile-flock-perl \
    libfile-mimeinfo-perl libfile-slurp-perl libgd-gd2-perl libhtml-restrict-perl \
    libimage-info-perl libimager-perl libimager-qrcode-perl libipc-run-perl libjson-perl \
    liblist-moreutils-perl liblist-utilsby-perl libmath-round-perl libnet-smtp-ssl-perl \
    libnet-sslglue-perl libparams-validate-perl libpbkdf2-tiny-perl libpdf-api2-perl \
    libregexp-ipv6-perl librest-client-perl librose-db-object-perl librose-db-perl \
    librose-object-perl libset-infinite-perl libsort-naturally-perl \
    libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl libtext-iconv-perl \
    libtext-unidecode-perl libtry-tiny-perl liburi-perl libwww-perl libxml-libxml-perl \
    libxml-writer-perl libyaml-perl libmail-imapclient-perl libencode-imaputf7-perl \
    poppler-utils python3-passlib \
    libuuid-tiny-perl build-essential libpq-dev ruby-dev libreadline-dev \
    libapache2-mod-passenger

# Print
RUN apt install -y \
    texlive-base-bin texlive-latex-recommended texlive-latex-base \
    texlive-fonts-recommended texlive-latex-extra texlive-lang-german \
    ghostscript texlive-lang-greek

# Kivitendo
RUN cd /var/www \
 && wget https://github.com/kivitendo/kivitendo-erp/archive/refs/tags/release-3.9.2.tar.gz \
 && tar -xvzf release-3.9.2.tar.gz \
 && mv kivitendo-erp-release-3.9.2 kivitendo-erp \
 && rm release-3.9.2.tar.gz \
 && cd /var/www/kivitendo-erp \
 # https://forum.kivitendo.ch/5784/nach-update-auf-latex-2021-file-scrpage2-sty-not-found
 && sed -i 's/scrpage2/scrlayer-scrpage/g' /var/www/kivitendo-erp/templates/print/RB/inheaders.tex \
 && sed -i "s/^latex =.*/latex = pdflatex/g" /var/www/kivitendo-erp/config/kivitendo.conf.default \
 && perl scripts/installation_check.pl -l \
 && mkdir webdav

# Api https://github.com/jfqd/kivitendo_rest_api
ARG API_COMMIT=6f51ac2aaa57bad5e94aee702ee2ec5491af2431
RUN cd /var/www \
 && wget -O api.zip https://github.com/jfqd/kivitendo_rest_api/archive/${API_COMMIT}.tar.gz \
 && tar -xvzf api.zip \
 && mv kivitendo_rest_api-* kivitendo-api \
 && rm api.zip \
 && cd /var/www/kivitendo-api \
 && gem install bundler \
 && bundle install --without development test

ADD docker-supervisord.conf /etc/supervisor/conf.d/
ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD kivitendo/kivitendo.conf /var/www/kivitendo-erp/config/
ADD kivitendo/01-short.yaml /var/www/kivitendo-erp/menus/user/
ADD apache/apache.conf /etc/apache2/sites-enabled/kivitendo.conf
ADD apache/fcgid_extra.conf /etc/apache2/mods-enabled/fcgid_extra.conf
ADD api/database.yml /var/www/kivitendo-api/config/
ADD api/secrets.yml /var/www/kivitendo-api/config/

# Apache & Permissions
RUN a2enmod fcgid && a2enmod rewrite \
 && sudo a2enmod passenger \
 && cd /var/www/kivitendo-erp \
 && chown -R www-data:www-data webdav spool \
 && chown www-data templates users \
 && chmod -R +x * \
 && rm /etc/apache2/sites-*/*default* \
 && mkdir -p /var/run/apache2 \
 && chmod -R +x /docker-entrypoint.sh \
 && a2enmod cgi && gem install pg

WORKDIR /var/www
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["exec", "supervisord",  "-n"]
