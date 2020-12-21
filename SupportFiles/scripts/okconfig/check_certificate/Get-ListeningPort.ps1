<#
.Synopsis
Enumerate local listening ports.
.DESCRIPTION
Enumerate all of the local listening ports on a computer (IPv4 only). Requires command Get-NetTCPConnection.
.PARAMETER Ports
The Ports parameter is defaulted to a list of popular server ports.
.EXAMPLE
Get-ListeningPort
LocalAddress                        LocalPort RemoteAddress                       RemotePort State       AppliedSetting OwningProcess 
------------                        --------- -------------                       ---------- -----       -------------- -------------
0.0.0.0                             3389      0.0.0.0                             0          Listen                     1116
.EXAMPLE
Get-ListeningPort -Ports 80,443
.NOTES
Created by: Jason Wasser
Modified: 1/23/2020
#>
function Get-ListeningPort {
    param (
        $Ports = @(22,25,443,465,587,636,993,995,3389)
    )
    
    $IPv4Regex = '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'
    $ListeningPorts = Get-NetTCPConnection -State Listen | Where-Object -FilterScript {$_.LocalAddress -match $IPv4Regex}
    foreach ($Port in $ListeningPorts) {
        if ($Ports -contains $Port.LocalPort) {
            Write-Output $Port
        }
    }
}
