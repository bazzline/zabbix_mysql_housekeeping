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
    #call this script (${0}) again with sudo with all provided arguments (${@})
    sudo "${0}" "${@}"

    exit ${?}
fi
#end of check if we are root

#begin of uninstall routine
systemctl disable weekly-zabbix-housekeeping.timer

rm /etc/systemd/system/zabbix-housekeeping.service
rm /etc/systemd/system/weekly-zabbix-housekeeping.timer

rm /etc/net.bazzline/zabbix/housekeeping/zabbix-housekeeping.service
rm /etc/net.bazzline/zabbix/housekeeping/weekly-zabbix-housekeeping.timer
rm /etc/net.bazzline/zabbix/housekeeping/housekeeping.sh

mv /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh /etc/net.bazzline/zabbix/housekeeping/local_configuration.sh.save

echo ":: Configuration file saved."
echo "   >>/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh<<."
echo "   You can remove the path >>/etc/net.bazzline/zabbix<< if you want to."

systemctl daemon-reload
#end of uninstall routine
