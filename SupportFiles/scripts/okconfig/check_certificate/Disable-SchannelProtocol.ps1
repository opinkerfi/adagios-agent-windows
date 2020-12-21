<#
.Synopsis
Disable SSL/TLS protocols Schannel settings in the registry.
.DESCRIPTION
Disable SSL/TLS protocols Schannel settings in the registry including
client and server components.
.PARAMETER Protocol
Specify the protocol you want to disable.
.EXAMPLE
Disable-SchannelProtocol -Protocol TLS1.0
.EXAMPLE
Disable-SchannelProtocol -Protocol SSL2,SSL3,TLS1.0,TLS1.1
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020 
#>
function Disable-SchannelProtocol {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]    
        [ValidateSet('SSL2', 'SSL3', 'TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3')]
        [string[]]$Protocol
    )
    begin { }
    process {
        foreach ($Proto in $Protocol) {
            Set-SchannelProtocol -Protocol $Proto -Setting Enabled -Value 0
            Set-SchannelProtocol -Protocol $Proto -Setting DisabledByDefault -Value 1
            Get-SchannelProtocol -Protocol $Proto
            }
        }
    end { }
}