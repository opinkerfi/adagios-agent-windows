<#
.Synopsis
Test local listening ports for certificate health.
.DESCRIPTION
Test local listening ports for certificate health.
Enumerate a list of local listening ports and then validate the certificate health.
.PARAMETER Ports
The Ports parameter is defaulted to a list of popular server ports.
.EXAMPLE
Test-LocalNetPortCertificate
.EXAMPLE
Test-LocalNetPortCertificate -Ports 80,443,3389
.NOTES
Created by: Jason Wasser
Modified: 1/9/2020 02:16:05 PM 
Todo: 
* Need to verify if this supports server name indication (SNI) for certificates
#>
function Test-LocalNetPortCertificate {
    param (
        $Ports = @(22,25,443,465,587,636,993,995,3389)
    )
    
    $ListeningPorts = Get-ListeningPort -Ports $Ports
    foreach ($Port in $ListeningPorts) {
        if ($Port.LocalAddress -eq '0.0.0.0') {
            Get-NetCertificateHealth -ComputerName 127.0.0.1 -Port $Port.LocalPort
        }
        else {
            Get-NetCertificateHealth -ComputerName $Port.LocalAddress -Port $Port.LocalPort
        }
    }
}