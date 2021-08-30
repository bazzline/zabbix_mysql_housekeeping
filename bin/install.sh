#!/bin/bash
####
# @since: 2021-08-30
# @author: stev leibelt <artodeto@bazzline.net>
####
#end of variables declaration
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

cat > /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh<<DELIM
CURRENT_VERSION=1

DB_USERNAME='<your user name>'
DB_PASSWORD='<your user password>'
DELIM

echo ":: Please add missing values to the configuration file."
echo "   Path >>\${CONFIGURATION_FILE_PATH}<<."

cat > /etc/net.bazzline/zabbix/housekeeping/housekeeping.sh<<DELIM
#!/bin/bash
####
# @since: 2021-08-30
# @author: stev leibelt <artodeto@bazzline.net>
####

logger -i -p cron.debug "bo: maintenance."

CONFIGURATION_FILE_PATH="/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh"
EXPECTED_VERSION=1

if [[ -f \${CONFIGURATION_FILE_PATH} ]];
then
    source \${CONFIGURATION_FILE_PATH}
    
    if [[ \${CURRENT_VERSION} -ne \${EXPECTED_VERSION} ]];
    then
        logger -i -p cron.crit ":: Configuration version is wrong."
        logger -i -p cron.crit "   Expected >>\${EXPECTED_VERSION}<<, found >>\${CURRENT_VERSION}<<."
        
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

echo ":: Adding and enabling systemd files."
cp /etc/net.bazzline/zabbix/housekeeping/zabbix-housekeeping.service /etc/systemd/system/zabbix-housekeeping.service
cp /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.timer /etc/systemd/system/weekly-zabbix-housekeeping.timer

systemctl daemon-reload
systemctl enable weekly-zabbix-housekeeping.timer
#end of install routine
