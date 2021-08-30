# zabbix_mysql_housekeeping
free as in freedome zabbix mysql housekeeping script.

The current change log can be found [here](CHANGELOG.md).

The current documentation can be found [here](documentation).

This is a super basic version of [rsyslog_mysql_housekeeping](https://github.com/bazzline/rsyslog_mysql_housekeeping) but for zabbix.

This script creates a timer that runs once a week and optimize the tables `zabbix.history_uint` and `zabbix.history`.

The script comes with an [install](bin/install.sh)- and an [uninstall](bin/uninstall.sh) routine.
All configurable values are configured in `/etc/net.bazzline/zabbix/housekeeping/local_configuration.sh`.

## Installation

```
WORKING_DIRECTORY=$(pwd)
TEMPORARY_DIRECTORY=$(mktemp -d)

cd ${TEMPORARY_DIRECTORY}
git clone https://github.com/bazzline/zabbix_mysql_housekeeping .
sudo bash bin/install.sh

cd ${WORKING_DIRECTORY}

rm -fr ${TEMPORARY_DIRECTORY}
```

## Uninstallation

```
WORKING_DIRECTORY=$(pwd)
TEMPORARY_DIRECTORY=$(mktemp -d)

cd ${TEMPORARY_DIRECTORY}
git clone https://github.com/bazzline/zabbix_mysql_housekeeping .
sudo bash bin/uninstall.sh

cd ${WORKING_DIRECTORY}

rm -fr ${TEMPORARY_DIRECTORY}
```
