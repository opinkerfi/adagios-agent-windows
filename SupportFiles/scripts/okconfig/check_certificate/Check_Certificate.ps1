<#
.Synopsis
   Check the SSL certificates of a computer for expiring or expired certificates.
.DESCRIPTION
   Check-Certificate checks the local or remote computer certificate store for 
   expiring or expired SSL certificates. This script is designed to work with
   NSclient++ and Nagios to output format to be consumed by a Nagios monitoring
   server. Instructions for configuring the NSclient++ and Nagios server check 
   are included.

   The check defaults to check the LocalMachine personal certificate store for
   certificates expiring with 30-60 days. You can also check alternate certificate
   stores by specifying a different $CertificatePath. You can adjust the amount
   of days before a certificate is considered to be in a warning or critical state.

   Pre-requisites:
    * NSclient++ installed on Windows box.
    * check_nrpe check configured on Nagios server.

   Usage with NSClient++
   ---------------------
   Add an external command to your nsclient.ini:
   
   PSCheckCertificate=cmd /c echo scripts\Check-Certificate.ps1; exit($lastexitcode) | powershell.exe -command -

   Create a nagios service check:
   $USER1$/check_nrpe -H $HOSTADDRESS$ -u -t 90 -c $ARG1$
   ($ARG1$ = PSCheckCertificate)

.NOTES
   Created by: Jason Wasser
   Modified: 9/14/2015 04:19:05 PM  

   Version 1.0

   Changelog:
    * Initial script
.PARAMETER ComputerName
    Specify a remote computer or default to local computer.
.PARAMETER WarningDays
    Specify the amount of days before the certificate expiration should be in 
    warning state.
.PARAMETER CriticalDays
    Specify the amount of days before the certificate expiration should be in 
    critical state.
.PARAMETER CertificatePath
    Specify the path to the certificate store.
.PARAMETER ExcludedThumbprint
    Array of thumbprints of certificates that should be excluded from being checked.
    This would be used if there is a certificate that is expired, but do not need
    to be notified about it.
.EXAMPLE
   .\Check-Certificates.ps1
   Checks the localhost computer personal certificate store for expiring certificates.
.LINK
   https://gallery.technet.microsoft.com/Check-for-Expiring-0c2d6f6c 
#>
#Requires -Version 2.0
[CmdletBinding()]
Param
(
    # Name of the server, defaults to local
    [Parameter(Mandatory=$false,
                ValueFromPipelineByPropertyName=$true,
                Position=0)]
    [string]$ComputerName=$env:COMPUTERNAME,
    [int]$returnStateOK = 0,
    [int]$returnStateWarning = 1,
    [int]$returnStateCritical = 2,
    [int]$returnStateUnknown = 3,
    [int]$WarningDays = 60,
    [int]$CriticalDays = 30,
    [string]$CertificatePath = 'Cert:\LocalMachine\My',
    [string[]]$ExcludedThumbprint#=@('DFE816240B40151BBCD7529D4C55627A8CE1671C')
)

Begin
{
}
Process
{
    
    # Get the certificates from the specified computer.
    try {
        # Use local path if it is localhost
        if ($ComputerName -eq $env:COMPUTERNAME) {
            $Certificates = Get-ChildItem -Path $CertificatePath -ErrorAction Stop -Exclude $ExcludedThumbprint
            }
        # Use PSRP if computer is not localhost
        else {
            $Certificates = Invoke-Command -ComputerName $ComputerName -ScriptBlock {param($CertificatePath,$ExcludedThumbprint) Get-ChildItem -Path $CertificatePath -Exclude $ExcludedThumbprint} -ArgumentList $CertificatePath,$ExcludedThumbprint -ErrorAction Stop
            }
        }
    # Catch all exceptions
    catch {
        Write-Output "Unable to get certificates from $ComputerName.|" ; exit $returnStateUnknown
        }
    
    # Filter warning and critical certificates.
    $WarningCertificates = $Certificates | Where-Object -FilterScript {$_.NotAfter -le (Get-Date).AddDays($WarningDays) -and $_.NotAfter -gt (Get-Date).AddDays($CriticalDays)} | Select Subject, NotAfter, @{Label="Days";Expression={($_.NotAfter - (Get-Date)).Days}}
    $CriticalCertificates = $Certificates | Where-Object -FilterScript {$_.NotAfter -le (Get-Date).AddDays($CriticalDays)} | Select Subject, NotAfter, @{Label="Days";Expression={($_.NotAfter - (Get-Date)).Days}}

    # If we have either warning or critical certificates, generate list and output status code.
    if ($WarningCertificates -or $CriticalCertificates) {
        # If we have critical AND warning certificates, generate list and output status code.
        if ($CriticalCertificates -and $WarningCertificates) {
            $CertificatesMessage = "Critical Certificates:`n"
            foreach ($CriticalCertificate in $CriticalCertificates) {
                $CertificatesMessage += "$($CriticalCertificate.Subject.Split(',')[0]) expires $($CriticalCertificate.NotAfter) $($CriticalCertificate.Days) days.`n"
                }
            $CertificatesMessage += "Warning Certificates:`n"
            foreach ($WarningCertificate in $WarningCertificates) {
                $CertificatesMessage += "$($WarningCertificate.Subject.Split(',')[0]) expires $($WarningCertificate.NotAfter) $($WarningCertificate.Days) days.`n"
                }
            Write-Output "$CertificatesMessage|" ; exit $returnStateCritical
            }
        # If we have only critical certificates.
        elseif ($CriticalCertificates) {
            $CertificatesMessage = "Critical Certificates:`n"
            foreach ($CriticalCertificate in $CriticalCertificates) {
                $CertificatesMessage += "$($CriticalCertificate.Subject.Split(',')[0]) expires $($CriticalCertificate.NotAfter) $($CriticalCertificate.Days) days.`n"
                }
            Write-Output "$CertificatesMessage|" ; exit $returnStateCritical
            }
        # If we have only warning certificates.  
        elseif ($WarningCertificates) {
            $CertificatesMessage = "Warning Certificates:`n"
            foreach ($WarningCertificate in $WarningCertificates) {
                $CertificatesMessage += "$($WarningCertificate.Subject.Split(',')[0]) expires $($WarningCertificate.NotAfter) $($WarningCertificate.Days) days.`n"
                }
            Write-Output "$CertificatesMessage|" ; exit $returnStateWarning
            }
        else {}
        }
    else {
        # No problems found
        Write-Output "Certificates OK.|" ; exit $returnStateOK
        }
}
End
{
}