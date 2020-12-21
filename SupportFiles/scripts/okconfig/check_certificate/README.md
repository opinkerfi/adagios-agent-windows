# CertificateHealth PowerShell Module #

The **CertificateHealth** PowerShell module has the following purposes:
* Validate local and remote certificate health (i.e. expiration, key length, deprecated signature algorithms)
* Test remote servers certificates and SSL/TLS protocols
* Validate the Schannel registry values of a Windoows system for the enforcement of the SSL/TLS protocols.
* Set, disable, enable Schannel protocols
* Enable strict TLS 1.2 schannel protocols

~~~~
CommandType Name                               Version Source
----------- ----                               ------- ------
Function    Disable-SchannelProtocol           1.7     CertificateHealth
Function    Enable-SchannelProtocol            1.7     CertificateHealth
Function    Enable-SchannelProtocolStrictTLS12 1.7     CertificateHealth
Function    Get-CertificateFile                1.7     CertificateHealth
Function    Get-CertificateHealth              1.7     CertificateHealth
Function    Get-ListeningPort                  1.7     CertificateHealth
Function    Get-NetCertificate                 1.7     CertificateHealth
Function    Get-NetCertificateHealth           1.7     CertificateHealth
Function    Get-SchannelProtocol               1.7     CertificateHealth
Function    Get-UnhealthyCertificate           1.7     CertificateHealth
Function    Get-UnhealthyCertificateNagios     1.7     CertificateHealth
Function    Save-NetCertificate                1.7     CertificateHealth
Function    Set-SchannelProtocol               1.7     CertificateHealth
Function    Test-LocalNetPortCertificate       1.7     CertificateHealth
Function    Test-NetSslProtocol                1.7     CertificateHealth
Function    Test-SchannelProtocolStrictTLS12   1.7     CertificateHealth