#!/bin/bash
####
# @since: 2021-08-30
# @author: stev leibelt <artodeto@bazzline.net>
####
#end of variables declaration
CONFIGURATION_FILE_EXPECTED_VERSION=1
CONFIGURATION_FILE_PATH="/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh"
WHO_AM_I=$(whoami)
#end of variables declaration

#begin of check if we are root
if [[ ${WHO_AM_I} != "root" ]];
then
    echo ":: Script needs to be executed as root."

    exit 1
fi
#end of check if we are root

#begin of install routine
echo ":: Creating files."
mkdir -p /etc/net.bazzline/zabbix/housekeeping

#   begin of configuration file
echo ":: Please input your zabbix database user name."
read DB_USERNAME

echo ":: Please input your zabbix database user password."
read DB_PASSWORD

cat > /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh<<DELIM
#!/bin/bash
####
# @author: https://github.com/bazzline/zabbix_mysql_housekeeping/blob/main/bin/install.sh
####

CURRENT_VERSION=1

DB_USERNAME='${DB_USERNAME}'
DB_PASSWORD='<${DB_PASSWORD}>'
DELIM

echo ":: Please check the configuration file."
echo "   Path >>${CONFIGURATION_FILE_PATH}<<."
#   end of configuration file

#   begin of executable file
cat > /etc/net.bazzline/zabbix/housekeeping/housekeeping.sh<<DELIM
#!/bin/bash
####
# @since: 2021-08-30
# @author: stev leibelt <artodeto@bazzline.net>
####

logger -i -p cron.debug "bo: maintenance."

CONFIGURATION_FILE_PATH='/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh'
CONFIGURATION_FILE_EXPECTED_VERSION=1

if [[ -f \${CONFIGURATION_FILE_PATH} ]];
then
    source \${CONFIGURATION_FILE_PATH}
    
    if [[ \${CURRENT_VERSION} -ne \${CONFIGURATION_FILE_EXPECTED_VERSION} ]];
    then
        logger -i -p cron.crit ":: Configuration version is wrong."
        logger -i -p cron.crit "   Expected >>\${CONFIGURATION_FILE_EXPECTED_VERSION}<<, found >>\${CURRENT_VERSION}<<."
        
        exit 2
    fi
else
    logger -i -p cron.crit ":: Expected configuration file not found."
    logger -i -p cron.crit "   >>\${CONFIGURATION_FILE_PATH}<< is not a file."
    
    exit 1
fi

logger -i -p cron.notice "   Starting >>optimize<< for table >>zabbix.history_uint<<."
mysqlcheck -u\${DB_USERNAME} -p\${DB_PASSWORD} --optimize zabbix history_uint;

logger -i -p cron.notice "   Starting >>optimize<< for table >>zabbix.history<<."
mysqlcheck -u\${DB_USERNAME} -p\${DB_PASSWORD} --optimize zabbix history;

logger -i -p cron.debug "eo: maintenance."
DELIM

chmod +x /etc/net.bazzline/zabbix/housekeeping/housekeeping.sh
#   end of executable file

#   begin of service file
cat > /etc/net.bazzline/zabbix/housekeeping/zabbix-housekeeping.service<<DELIM
[Unit]
Description=net.bazzline zabbix housekeeping service
ConditionACPower=true
After=zabbix-server-mysql.service

[Service]
Type=oneshot
ExecStart=/etc/net.bazzline/zabbix/housekeeping/housekeeping.sh
KillMode=process
TimeoutStopSec=21600
DELIM
#   end of service file

#   end of timer file
#   begin of timer file
cat > /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.timer<<DELIM
[Unit]
Description=Weekly zabbix mysql housekeeping

[Timer]
OnCalendar=Sat *-*-* 05:00
RandomizedDelaySec=42
Persistent=true
Unit=zabbix-housekeeping.service

[Install]
WantedBy=timers.target
DELIM
#   end of timer file

echo ":: Adding and enabling systemd files."
cp /etc/net.bazzline/zabbix/housekeeping/zabbix-housekeeping.service /etc/systemd/system/zabbix-housekeeping.service
cp /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.timer /etc/systemd/system/weekly-zabbix-housekeeping.timer

systemctl daemon-reload
systemctl enable weekly-zabbix-housekeeping.timer
#end of install routine
