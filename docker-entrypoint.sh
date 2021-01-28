#!/usr/bin/env bash

cd /var/www/kivitendo-erp
chown -R www-data:www-data webdav spool
chown www-data templates users

KIVI_CONFIG="config/kivitendo.conf"

sed -i "s/\$ADMIN_PASSWORD/$ADMIN_PASSWORD/g" $KIVI_CONFIG
sed -i "s/\$DB_HOST/$DB_HOST/g" $KIVI_CONFIG
sed -i "s/\$DB_PORT/$DB_PORT/g" $KIVI_CONFIG
sed -i "s/\$DB_NAME/$DB_NAME/g" $KIVI_CONFIG
sed -i "s/\$DB_USER/$DB_USER/g" $KIVI_CONFIG
sed -i "s/\$DB_PASSWORD/$DB_PASSWORD/g" $KIVI_CONFIG

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

if [ $START_TASK_SERVER == "1" ]; then
  sed -i "s/^autostart.*$/autostart\=true/" /etc/supervisor/conf.d/docker-supervisord.conf
else
  sed -i "s/^autostart.*$/autostart\=false/" /etc/supervisor/conf.d/docker-supervisord.conf
fi

$@
