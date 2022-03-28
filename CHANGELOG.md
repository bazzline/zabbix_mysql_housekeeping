# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Open]

### To Add

### To Change

* Align code to [zabbix_agent_update_notifyer](https://github.com/bazzline/zabbix_agent_update_notifyer)
    * Create `version` file
    * Move installation path from `/etc/net.bazzline` to `/opt/net_bazzline`

## [Unreleased]

### Added

### Changed

* Replaced stopping of scripts with automatically elevating by prefixing with sudo if scripts are not started as root

## [0.1.0](https://github.com/bazzline/zabbix_mysql_housekeeping/tree/0.1.0) - 20220318

### Added

* [install.sh](bin/install.sh)
* [uninstall.sh](bin/uninstall.sh)
