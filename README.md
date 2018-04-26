# Adagios | OKconfig agent - Unattended Installation for Windows
Installs NSClient (32/64 bit) in NRPE mode with your favorite settings and plugins.
This setup works with Adagios setups. Adagios is a web based Nagios configuration interface.
Project website is at http://adagios.org

## Installation

### Download this repo as zip file to your windows server
https://github.com/gardart/nagios-nsclient-install/archive/master.zip

### Change configuration settings

* Change the file `Files/allowed_hosts.ini`
```
[/settings/default]
allowed hosts = 127.0.0.1,{ip_address_of_your_nagios_server}
```

* `Optional:` Make your changes in `Files/nsclient.ini` . This configuration is currently configured for NRPE mode

### Install NSClient++

Run Deploy-Application.exe to begin silent unattended installation. 

The installation script will do the following:

* Stop NSClient++ service
* Uninstall/Update older NSClients
* Install the correct package depending on your system architecture (32/64 bit)
* Install Firewall Rules for NSClient++
* Install your custom plugins and config files
* Start the NSClient++ service
