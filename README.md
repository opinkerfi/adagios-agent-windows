# Adagios | OKconfig agent - Unattended Installation for Windows
Installs NSClient (32/64 bit) in NRPE mode with your favorite settings and plugins.
This setup works with Adagios setups. Adagios is a web based Nagios configuration interface.
Project website is at http://adagios.org

# Installation

## Install with Powershell
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri "https://github.com/opinkerfi/adagios-agent-windows/archive/master.zip" -outfile "$env:TEMP\master.zip" -Verbose

Expand-Archive -Path "$env:TEMP\master.zip" -DestinationPath "$env:TEMP" -Force -Verbose
& "$env:TEMP\adagios-agent-windows-master\Deploy-Application.exe"

$ENV:Path += ";C:\Program Files\NSclient++"
```

### Change configuration settings

* Change the file `SupportFiles/allowed_hosts.ini`
```
[/settings/default]
allowed hosts = 127.0.0.1,{ip_address_of_your_nagios_server}
```

To update allowed hosts from the command line, run

```
nscp.exe settings --path /settings/default --key "allowed hosts" --set "127.0.0.1,::1,monitoring-server
nscp.exe settings --list --path /settings/default --key "allowed hosts"

# Restart NSClient++
nscp.exe service --stop
nscp.exe service --start
```

* `Optional:` Make your changes in `Files/nsclient.ini` . This configuration is currently configured for NRPE mode

## Manual Installation

Download this repo as zip file to your windows server
https://github.com/opinkerfi/adagios-agent-windows/archive/master.zip

Run Deploy-Application.exe to begin silent unattended installation. 

The installation script will do the following:

* Stop NSClient++ service
* Uninstall/Update older NSClients
* Install the correct package depending on your system architecture (32/64 bit)
* Install Firewall Rules for NSClient++
* Install your custom plugins and config files
* Start the NSClient++ service
