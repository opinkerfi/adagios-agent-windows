<#
.Synopsis
   Get-UnhealhtyCertificateNagios checks the local certificate store or file system for 
   unhealthy SSL certificates. 
.DESCRIPTION
   Get-UnhealhtyCertificateNagios checks the local certificate store or file system for 
   unhealthy SSL certificates. Get-UnhealthyCertificate uses the Get-CertificateHealth
   function from the CertificateHealth module to find certificates that have
   expired or are expiring soon. It also checks for certificates using deprecated
   or vulnerable signature algorithms. 
   
   
   This script is designed to work with NSclient++ and Nagios to output in a format 
   to be consumed by a Nagios monitoring server. Instructions for configuring the 
   NSclient++ and Nagios server check are included.

   The check defaults to check the LocalMachine personal certificate store for
   certificates expiring with 30-60 days. You can also check alternate certificate
   paths by specifying a different $CertificatePath. You can adjust the amount
   of days before a certificate is considered to be in a warning or critical state.

   Pre-requisites:
    * NSclient++ installed on Windows box.
    * check_nrpe check configured on Nagios server.

   Usage with NSClient++
   ---------------------
   Add an external command to your nsclient.ini:
   
   PSCheckCertificate=cmd /c echo Import-Module scripts\CertificateHealth\CertificateHealth.psm1 ; Get-UnhealthyCertificateNagios ; exit($lastexitcode) | powershell.exe -command -

   If you'd like to create a global exclusion list to not be monitored, add them to the 
   ExcludedThumbprint.txt at the root of the module and set your nsclient.ini to below: 

   PSCheckCertificate=cmd /c echo Import-Module scripts\CertificateHealth\CertificateHealth.psm1 ; Get-UnhealthyCertificateNagios -ExcludedThumbprint $ExcludedThumbprint ; exit($lastexitcode) | powershell.exe -command -

   Create a nagios service check:
   $USER1$/check_nrpe -H $HOSTADDRESS$ -u -t 90 -c $ARG1$
   ($ARG1$ = PSCheckCertificate)

.NOTES
   Created by: Jason Wasser
   Modified: 1/14/2016 10:17:58 AM 

   Version 1.5

   Changelog:
    v 1.5
     * fixed - missing $WarningKeySize and $CriticalKeySize when calling Get-CertificateHealth
    v 1.4
     * Added key size check
    v 1.3
     * Script renamed to use PowerShell approved verb.
     * Script now part of CertificateHealth module and uses associated functions.
    v 1.2
     * Added Hashing Algorithm to prepare for sha1 deprecation.
    v 1.0
     * Initial Script
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
.PARAMETER WarningAlgorithm
   Array of algorithms that are deprecated.
.PARAMETER CriticalAlgorithm
   Array of algorithms with known vulnerabilities.
.PARAMETER CritialKeySize
   Certificates with key size less than this value will be considered critical.
.PARAMETER WarningKeySize
   Certificates with key size less than this value and greater than the CriticalKeySize 
   will be considered warning.
.EXAMPLE
   Get-UnhealthyCertificates
   Checks the computer personal certificate store for unhealthy certificates.
.LINK
   https://gallery.technet.microsoft.com/scriptcenter/Certificate-Health-b646aeff
#>
#Requires -Version 2.0
function Get-UnhealthyCertificateNagios 
    {
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
        [string[]]$Path = 'Cert:\LocalMachine\My',
        [string[]]$ExcludedThumbprint,#=@('DFE816240B40151BBCD7529D4C55627A8CE1671C')
        [string[]]$WarningAlgorithm=('sha1RSA'),
        [string[]]$CriticalAlgorithm=('md5RSA'),
        [int]$CriticalKeySize=1024,
        [int]$WarningKeySize=2048,
        [switch]$Recurse=$false
    )

    Begin
    {
    }
    Process
    {
    
        # Get the certificates from the specified computer.
        try {
            $Certificates = Get-CertificateHealth -Path $Path -WarningDays $WarningDays -CriticalDays $CriticalDays -WarningAlgorithm $WarningAlgorithm -CriticalAlgorithm $CriticalAlgorithm -ExcludedThumbprint $ExcludedThumbprint -WarningKeySize $WarningKeySize -CriticalKeySize $CriticalKeySize -Recurse:([bool]$Recurse.IsPresent) -ErrorAction Stop
            }
        # Catch all exceptions
        catch {
            Write-Output "Unable to get certificates from $ComputerName.|" ; exit $returnStateUnknown
            }
    
        # Filter warning and critical certificates.
        $WarningCertificates = $Certificates | Where-Object -FilterScript {$_.ValidityPeriodStatus -eq 'Warning' -or $_.AlgorithmStatus -eq 'Warning' -or $_.KeySizeStatus -eq 'Warning'}
        $CriticalCertificates = $Certificates | Where-Object -FilterScript {$_.ValidityPeriodStatus -eq 'Critical' -or $_.AlgorithmStatus -eq 'Critical' -or $_.KeySizeStatus -eq 'Critical'}

        # If we have either warning or critical certificates, generate list and output status code.
        if ($WarningCertificates -or $CriticalCertificates) {
            
            # If we have critical AND warning certificates, generate list and output status code.
            if ($CriticalCertificates -and $WarningCertificates) {
                Write-Verbose 'Critical certificates and warning certificates found.'
                
                if ($CriticalCertificates.Count) {
                    $CertificatesMessage = "$($CriticalCertificates.Count) Critical Certificates found:`n"
                    }
                else {
                    $CertificatesMessage = "Critical Certificate found:`n"
                    }

                foreach ($CriticalCertificate in $CriticalCertificates) {
                    $CertificatesMessage += "$($CriticalCertificate.Subject) `($($CriticalCertificate.SignatureAlgorithm) $($CriticalCertificate.KeySize) bits`) expires $($CriticalCertificate.NotAfter) $($CriticalCertificate.Days) days.`n"
                    }

                if ($WarningCertificates.Count) {
                    $CertificatesMessage += "$($WarningCertificates.Count) Warning Certificates found:`n"
                    }
                else {
                    $CertificatesMessage += "Warning Certificate found:`n"
                    }

                foreach ($WarningCertificate in $WarningCertificates) {
                    $CertificatesMessage += "$($WarningCertificate.Subject) `($($WarningCertificate.SignatureAlgorithm) $($WarningCertificate.KeySize) bits`) expires $($WarningCertificate.NotAfter) $($WarningCertificate.Days) days.`n"
                    }
                Write-Output "$CertificatesMessage|" ; exit $returnStateCritical
                }

            # If we have only critical certificates.
            elseif ($CriticalCertificates) {
                Write-Verbose 'Critical certificates found.'
                
                
                if ($CriticalCertificates.Count) {
                    $CertificatesMessage = "$($CriticalCertificates.Count) Critical Certificates found:`n"
                    }
                else {
                    $CertificatesMessage = "Critical Certificate found:`n"
                    }

                foreach ($CriticalCertificate in $CriticalCertificates) {
                    $CertificatesMessage += "$($CriticalCertificate.Subject) `($($CriticalCertificate.SignatureAlgorithm) $($CriticalCertificate.KeySize) bits`) expires $($CriticalCertificate.NotAfter) $($CriticalCertificate.Days) days.`n"
                    }
                Write-Output "$CertificatesMessage|" ; exit $returnStateCritical
                }
            # If we have only warning certificates.  
            elseif ($WarningCertificates) {
                Write-Verbose 'Warning certificates found.'
                
                if ($WarningCertificates.Count) {
                    $CertificatesMessage += "$($WarningCertificates.Count) Warning Certificates found:`n"
                    }
                else {
                    $CertificatesMessage += "Warning Certificate found:`n"
                    }

                foreach ($WarningCertificate in $WarningCertificates) {
                    $CertificatesMessage += "$($WarningCertificate.Subject) `($($WarningCertificate.SignatureAlgorithm) $($WarningCertificate.KeySize) bits`) expires $($WarningCertificate.NotAfter) $($WarningCertificate.Days) days.`n"
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
}