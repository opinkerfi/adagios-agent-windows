<#
.Synopsis
Enables strict TLS 1.2 protocol Schannel settings in the registry.
.DESCRIPTION
Enables strict TLS 1.2 protocol Schannel settings in the registry.
.EXAMPLE
Enable-SchannelProtocolStrictTLS12

Protocol DisabledByDefault Enabled CommunicationMode
-------- ----------------- ------- -----------------
SSL2                  True   False Client
SSL2                  True   False Server
SSL3                  True   False Client
SSL3                  True   False Server
TLS1.0                True   False Client
TLS1.0                True   False Server
TLS1.1                True   False Client
TLS1.1                True   False Server
TLS1.2               False    True Client
TLS1.2               False    True Server
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020
#>
function Enable-SchannelProtocolStrictTLS12 {
    Disable-SchannelProtocol -Protocol SSL2,SSL3,TLS1.0,TLS1.1
    Enable-SchannelProtocol -Protocol TLS1.2
}