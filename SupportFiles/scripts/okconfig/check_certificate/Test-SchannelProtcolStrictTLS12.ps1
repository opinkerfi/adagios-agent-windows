<#
.Synopsis
Test for strick TLS 1.2 protocol Schannel settings in the registry.
.DESCRIPTION
Test for strick TLS 1.2 protocol Schannel settings in the registry including
client and server components.
.EXAMPLE
Test-SchannelProtocolStrictTLS12

False
.EXAMPLE
Test-SchannelProtocolStrictTLS12

True
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020
#>
function Test-SchannelProtocolStrictTLS12 {
    [cmdletbinding()]
    $SchannelProtocolStrictTLS12Status = $false
    $SchannelProtocol = Get-SchannelProtocol

    # Test Deprecated protocols
    $DeprecatedProtocols = $SchannelProtocol | Where-Object -FilterScript { $_.Protocol -in ('SSL2', 'SSL3', 'TLS1.0', 'TLS1.1') -and $_.DisabledByDefault -ne $true -and $_.Enabled -ne $false }
    if ($DeprecatedProtocols) {
        $EnabledDeprecatedProtocols = $true
    }
    else {
        $EnabledDeprecatedProtocols = $false
    }

    # Test TLS 1.2 is configured or Not Set
    $EnabledTls12Protocol = $SchannelProtocol | Where-Object -FilterScript { $_.Protocol -eq 'TLS1.2' -and $_.DisabledByDefault -in ('False', 'Not Set') -and $_.Enabled -in ('True', 'Not Set') }
    
    if ($EnabledTls12Protocol -and $EnabledDeprecatedProtocols -eq $false) {
        $SchannelProtocolStrictTLS12Status = $true
    }
    else {
        $SchannelProtocolStrictTLS12Status = $false
    }
    Write-Output $SchannelProtocolStrictTLS12Status
}