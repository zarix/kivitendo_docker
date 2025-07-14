#!/usr/bin/env bash

cd /var/www/kivitendo-erp
chown -R www-data:www-data webdav spool
chown www-data templates users

# Defaults
ADMIN_PASSWORD=${ADMIN_PASSWORD:-admin}
POSTGRES_HOST=${POSTGRES_HOST:-db}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_NAME=${POSTGRES_NAME:-kivitendo_auth}
POSTGRES_USER=${POSTGRES_USER:-kivitendo}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-kivitendo}
POSTGRES_KIVI_DB=${POSTGRES_KIVI_DB:-kivitendo}
AUTH_MODULE=${AUTH_MODULE:-DB}
START_TASK_SERVER=${START_TASK_SERVER:-0}
LDAP_HOST=${LDAP_HOST:-localhost}
LDAP_PORT=${LDAP_PORT:-389}
LDAP_TLS=${LDAP_TLS:-0}
LDAP_ATTR=${LDAP_ATTR:-uid}
LDAP_TIMEOUT=${LDAP_TIMEOUT:-10}
LDAP_VERIFY=${LDAP_VERIFY:-require}
MAIL_METHOD=${MAIL_METHOD:-smtp}
MAIL_HOST=${MAIL_HOST:-localhost}
MAIL_PORT=${MAIL_PORT:-25}
MAIL_SECURITY=${MAIL_SECURITY:-none}
SECRET_KEY_BASE=${SECRET_KEY_BASE:-none}
API_USER=${API_USER:-kivitendo}
API_PASSWORD=${API_PASSWORD:-kivitendo}

KIVI_CONFIG="config/kivitendo.conf"

sed -i "s/\$ADMIN_PASSWORD/$ADMIN_PASSWORD/g" $KIVI_CONFIG
sed -i "s/\$POSTGRES_HOST/$POSTGRES_HOST/g" $KIVI_CONFIG
sed -i "s/\$POSTGRES_PORT/$POSTGRES_PORT/g" $KIVI_CONFIG
sed -i "s/\$POSTGRES_NAME/$POSTGRES_NAME/g" $KIVI_CONFIG
sed -i "s/\$POSTGRES_USER/$POSTGRES_USER/g" $KIVI_CONFIG
sed -i "s/\$POSTGRES_PASSWORD/$POSTGRES_PASSWORD/g" $KIVI_CONFIG

sed -i "s/\$AUTH_MODULE/$AUTH_MODULE/g" $KIVI_CONFIG
sed -i "s/\$LDAP_HOST/$LDAP_HOST/g" $KIVI_CONFIG
sed -i "s/\$LDAP_PORT/$LDAP_PORT/g" $KIVI_CONFIG
sed -i "s/\$LDAP_TLS/$LDAP_TLS/g" $KIVI_CONFIG
sed -i "s/\$LDAP_ATTR/$LDAP_ATTR/g" $KIVI_CONFIG
sed -i "s/\$LDAP_BASEDN/$LDAP_BASEDN/g" $KIVI_CONFIG
sed -i "s/\$LDAP_FILTER/$LDAP_FILTER/g" $KIVI_CONFIG
sed -i "s/\$LDAP_BINDDN/$LDAP_BINDDN/g" $KIVI_CONFIG
sed -i "s/\$LDAP_BINDPW/$LDAP_BINDPW/g" $KIVI_CONFIG
sed -i "s/\$LDAP_TIMEOUT/$LDAP_TIMEOUT/g" $KIVI_CONFIG
sed -i "s/\$LDAP_VERIFY/$LDAP_VERIFY/g" $KIVI_CONFIG

sed -i "s/\$MAIL_METHOD/$MAIL_METHOD/g" $KIVI_CONFIG
sed -i "s/\$MAIL_HOST/$MAIL_HOST/g" $KIVI_CONFIG
sed -i "s/\$MAIL_PORT/$MAIL_PORT/g" $KIVI_CONFIG
sed -i "s/\$MAIL_SECURITY/$MAIL_SECURITY/g" $KIVI_CONFIG
sed -i "s/\$MAIL_LOGIN/$MAIL_LOGIN/g" $KIVI_CONFIG
sed -i "s/\$MAIL_PASSWORD/$MAIL_PASSWORD/g" $KIVI_CONFIG
sed -i "s/\$MAIL_FROM/$MAIL_FROM/g" $KIVI_CONFIG
sed -i "s/\$MAIL_TO/$MAIL_TO/g" $KIVI_CONFIG

if [ $START_TASK_SERVER == "1" ]; then
  sed -i "s/^autostart.*$/autostart\=true/" /etc/supervisor/conf.d/docker-supervisord.conf
else
  sed -i "s/^autostart.*$/autostart\=false/" /etc/supervisor/conf.d/docker-supervisord.conf
fi

cd /var/www/kivitendo-api
SEC_CONFIG="config/secrets.yml"
sed -i "s/\$SECRET_KEY_BASE/$SECRET_KEY_BASE/g" $SEC_CONFIG
API_CONFIG="config/database.yml"
sed -i "s/\$POSTGRES_HOST/$POSTGRES_HOST/g" $API_CONFIG
sed -i "s/\$POSTGRES_KIVI_DB/$POSTGRES_KIVI_DB/g" $API_CONFIG
sed -i "s/\$POSTGRES_USER/$POSTGRES_USER/g" $API_CONFIG
sed -i "s/\$POSTGRES_PASSWORD/$POSTGRES_PASSWORD/g" $API_CONFIG
AUTH_CONFIG="app/controllers/api/v1/api_controller.rb"
sed -i "s/Rails.application.secrets\[\:http_user\]/\"$API_USER\"/g" $AUTH_CONFIG
sed -i "s/Rails.application.secrets\[\:http_pwd\]/\"$API_PASSWORD\"/g" $AUTH_CONFIG

$@
