FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt install -y software-properties-common supervisor postgresql-client sudo && \
  add-apt-repository universe -y

# Basic Pakets
RUN apt-get update && apt install -y \ 
    apache2 libarchive-zip-perl libclone-perl \
    libconfig-std-perl libdatetime-perl libdbd-pg-perl libdbi-perl \
    libemail-address-perl  libemail-mime-perl libfcgi-perl libjson-perl \
    liblist-moreutils-perl libnet-smtp-ssl-perl libnet-sslglue-perl \
    libparams-validate-perl libpdf-api2-perl librose-db-object-perl \
    librose-db-perl librose-object-perl libsort-naturally-perl \
    libstring-shellquote-perl libtemplate-perl libtext-csv-xs-perl \
    libtext-iconv-perl liburi-perl libxml-writer-perl libyaml-perl \
    libimage-info-perl libgd-gd2-perl libapache2-mod-fcgid \
    libfile-copy-recursive-perl postgresql libalgorithm-checkdigits-perl \
    libcrypt-pbkdf2-perl git libcgi-pm-perl libtext-unidecode-perl libwww-perl \
    postgresql-contrib poppler-utils libhtml-restrict-perl \
    libdatetime-set-perl libset-infinite-perl liblist-utilsby-perl \
    libdaemon-generic-perl libfile-flock-perl libfile-slurp-perl \
    libfile-mimeinfo-perl libpbkdf2-tiny-perl libregexp-ipv6-perl \
    libdatetime-event-cron-perl libexception-class-perl libcam-pdf-perl \
    libxml-libxml-perl libtry-tiny-perl libmath-round-perl \
    libimager-perl libimager-qrcode-perl librest-client-perl libipc-run-perl \
    build-essential libpq-dev ruby-dev libreadline-dev

# Print
RUN apt install -y \
    texlive-base-bin texlive-latex-recommended texlive-fonts-recommended \
    texlive-latex-extra texlive-lang-german ghostscript

# Perl
RUN cpan Algorithm::CheckDigits Archive::Zip CAM::PDF CGI Clone Config::Std \
      Daemon::Generic DateTime DateTime::Event::Cron DateTime::Format::Strptime \
      DateTime::Set DBI DBD::Pg Email::Address Email::MIME Exception::Class FCGI \
      File::Copy::Recursive File::Flock File::MimeInfo File::Slurp GD HTML::Parser \
      HTML::Restrict Image::Info JSON List::MoreUtils List::UtilsBy \
      LWP::Authen::Digest LWP::UserAgent Net::SMTP::SSL Net::SSLGlue \
      Params::Validate PBKDF2::Tiny PDF::API2 Regexp::IPv6 Rose::Object \
      Rose::DB Rose::DB::Object Set::Infinite String::ShellQuote Sort::Naturally \
      Template Text::CSV_XS Text::Iconv Text::Unidecode URI YAML::XS Math::Round \
      IPC::Run Imager Imager::QRCode Rest::Client Term::ReadLine::Gnu || :

# Kivitendo
RUN cd /var/www \
 && git clone https://github.com/kivitendo/kivitendo-erp.git \
 && cd /var/www/kivitendo-erp \
 && git checkout release-3.7.0 \
 && perl scripts/installation_check.pl -l \
 && mkdir webdav

ENV APACHE_RUN_DIR=/var/run/apache2
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

ADD docker-supervisord.conf /etc/supervisor/conf.d/
ADD kivitendo.conf /var/www/kivitendo-erp/config/
ADD 01-short.yaml /var/www/kivitendo-erp/menus/user/
ADD apache.conf /etc/apache2/sites-enabled/kivitendo.conf
ADD fcgid_extra.conf /etc/apache2/mods-enabled/fcgid_extra.conf
ADD docker-entrypoint.sh /docker-entrypoint.sh

# Apache & Permissions
RUN a2enmod fcgid && a2enmod rewrite \
 && cd /var/www/kivitendo-erp \
 && chown -R www-data:www-data webdav spool \
 && chown www-data templates users \
 && chmod -R +x * \
 && rm /etc/apache2/sites-*/*default* \
 && mkdir -p /var/run/apache2 \
 && chmod -R +x /docker-entrypoint.sh \
 && a2enmod cgi  && gem install pg

WORKDIR /var/www
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["exec", "supervisord",  "-n"]
