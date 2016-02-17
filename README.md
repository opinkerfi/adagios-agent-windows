# NSClient++ - Unattended Installation Script for Windows
Installs NSClient (32/64 bit) in NRPE mode with your favorite settings and plugins.

## Folder and file structure

## Installation

### Change configuration ini files to suit your environment

1. files/allowed_hosts.ini -> ip address of your Nagios monitoring server
2. files/nsclient.ini -> main configuration, currently configured for NRPE mode

### Install

Run Unattended_Setup.vbs to begin silent unattended installation. The script will stop NSClient++ service, install the correct package depending on your system architecture (32/64 bit), install your custom plugins and config files and restart the NSClient++ service.
If you have older msi setup of NSClient++, it will be updated.

