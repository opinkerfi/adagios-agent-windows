<#
.Synopsis
Enable SSL/TLS protocols Schannel settings in the registry.
.DESCRIPTION
Enable SSL/TLS protocols Schannel settings in the registry including
client and server components.
.PARAMETER Protocol
Specify the protocol you want to enable.
.EXAMPLE
Enable-SchannelProtocol -Protocol TLS1.2
.EXAMPLE
Enable-SchannelProtocol -Protocol TLS1.0,TLS1.1
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020
#>
function Enable-SchannelProtocol {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('SSL2', 'SSL3', 'TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3')]
        [string[]]$Protocol
    )
    begin { }
    process {
        foreach ($Proto in $Protocol) {
            Set-SchannelProtocol -Protocol $Proto -Setting Enabled -Value 1
            Set-SchannelProtocol -Protocol $Proto -Setting DisabledByDefault -Value 0
            Get-SchannelProtocol -Protocol $Proto
            }
        }
    end { }
}