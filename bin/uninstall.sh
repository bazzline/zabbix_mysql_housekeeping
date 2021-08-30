#!/bin/bash
####
# @since: 2021-08-30
# @author: stev leibelt <artodeto@bazzline.net>
####
#begin of variables declaration
WHO_AM_I=$(whoami)
#end of variables declaration

#begin of check if we are root
if [[ ${WHO_AM_I} != "root" ]];
then
    echo ":: Script needs to be executed as root."

    exit 1
fi
#end of check if we are root

#begin of uninstall routine
systemctl enable zabbix-housekeeping.timer

rm /etc/systemd/system/zabbix-housekeeping.service
rm /etc/systemd/system/zabbix-housekeeping.timer

rm /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.service
rm /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.timer
rm /etc/net.bazzline/zabbix/housekeeping/housekeeping.sh

mv /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh.save

echo ":: Configuration file saved."
echo "   >>/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh<<."
echo "   You can remove the path >>/etc/net.bazzline/zabbix<< if you want to."

systemctl daemon-reload
#end of uninstall routine
