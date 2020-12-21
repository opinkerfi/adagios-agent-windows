<#
.Synopsis
Set the SSL and TLS protocol Schannel settings in the registry.
.DESCRIPTION
Set the SSL and TLS protocol Schannel settings in the registry including
client and server components.
.PARAMETER Protocol
Specify the protocol you want to query.
.PARAMETER CommunicationMode
Specify the communication mode: server/client.
.EXAMPLE
Set-SchannelProtocol -Protocol TLS1.0 -Setting Enabled -Value 0
.EXAMPLE
Set-SchannelProtocol -Protocol TLS1.1 -CommunicationMode Server -Setting DisabledByDefault -Value 1
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020
#>
function Set-SchannelProtocol {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('SSL2', 'SSL3', 'TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3')]
        [string[]]$Protocol,
        [ValidateSet('Client', 'Server')]
        [string[]]$CommunicationMode = ('Client', 'Server'),
        [Parameter(Mandatory)]
        [ValidateSet('Enabled', 'DisabledByDefault')]
        [string]$Setting,
        [Parameter(Mandatory)]
        [ValidateSet(0, 1)]
        [int]$Value
    )
    begin {
        $SCHANNELProtocolsRegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols'
        function Set-Protocol {
            param (
                [ValidateSet('SSL2', 'SSL3', 'TLS1.0', 'TLS1.1', 'TLS1.2', 'TLS1.3')]
                [string]$Protocol,
                [ValidateSet('Client', 'Server')]
                [string]$Mode,
                [ValidateSet('Enabled', 'DisabledByDefault')]
                [string]$Setting,
                [ValidateSet(0, 1)]
                [int]$Value
            )

            try {
                Write-Verbose "Setting $Setting for Protocol $Proto $Mode at $SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode to $Value"
                Set-ItemProperty -Path "$SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode" -Name $Setting -Value $Value -ErrorAction Stop | Out-Null
            }
            catch [System.Exception] {
                switch ($_.Exception.GetType().FullName) {
                    'System.Management.Automation.ItemNotFoundException' {
                        Write-Verbose "Unable to set protocol status value at $SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode"
                    }
                    default {
                        Write-Verbose "Unknown error"
                    }    
                }
            }
        }
    }
    process {
        foreach ($Proto in $Protocol) {
            foreach ($Mode in $CommunicationMode) {
                switch ($Proto) {
                    'SSL2' {
                        $ProtocolName = 'SSL 2.0'
                    }
                    'SSL3' {
                        $ProtocolName = 'SSL 3.0'
                    }
                    'TLS1.0' {
                        $ProtocolName = 'TLS 1.0'
                    }
                    'TLS1.1' {
                        $ProtocolName = 'TLS 1.1'
                    }
                    'TLS1.2' {
                        $ProtocolName = 'TLS 1.2'
                    }
                    'TLS1.3' {
                        $ProtocolName = 'TLS 1.3'
                    }
                }
                Write-Verbose "Attempting to set $Setting for Protocol $Proto $Mode at $SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode to $Value"
                Write-Verbose "Checking if $SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode exists"
                if (Test-Path -Path "$SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode") {
                    Write-Verbose "$SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode exists."
                    Set-Protocol -Protocol $Proto -Mode $Mode -Setting $Setting -Value $Value
                }
                else {
                    Write-Verbose "$SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode does not exist. Creating now."
                    New-Item -Path "$SCHANNELProtocolsRegistryPath\$ProtocolName\$Mode" -Force | Out-Null
                    Set-Protocol -Protocol $Proto -Mode $Mode -Setting $Setting -Value $Value
                }
                #Get-SchannelProtocol -Protocol $Proto -CommunicationMode $Mode
            }
        }
    }
    end { }
}