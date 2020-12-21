<#
.Synopsis
   Get-UnhealhtyCertificate checks the local certificate store or file system for 
   unhealthy SSL certificates. 
.DESCRIPTION
   Get-UnhealhtyCertificate checks the local certificate store or file system for 
   unhealthy SSL certificates. Get-UnhealthyCertificate uses the Get-CertificateHealth
   function from the CertificateHealth module to find certificates that have
   expired or are expiring soon. It also checks for certificates using deprecated
   or vulnerable signature algorithms. 

.NOTES
   Created by: Jason Wasser
   Modified: 9/28/2016 11:24:57 AM    

   Version 1.6

   Changelog:
    v 1.6
     * Added remote computer support through PSRP
    v 1.5
     * Added certificate key size health check
    v 1.4
     * Separated Nagios output to a separate function.
    v 1.3
     * Script renamed to use PowerShell approved verb.
     * Script now part of CertificateHealth module and uses associated functions.
    v 1.2
     * Added Hashing Algorithm to prepare for sha1 deprecation.
    v 1.0
     * Initial Script
.PARAMETER ComputerName
    Specify a remote computer. 
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
   Get-UnhealthyCertificate
   Checks the computer personal certificate store for unhealthy certificates.
.EXAMPLE
   Get-UnhealthyCertificate -Path C:\Temp,Cert:\LocalMachine\My
   Checks the computer personal certificate store and C:\temp for unhealthy certificates.
.LINK
   https://gallery.technet.microsoft.com/scriptcenter/Certificate-Health-b646aeff
#>
#Requires -Version 2.0
function Get-UnhealthyCertificate 
    {
    [CmdletBinding()]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string[]]$Path = 'Cert:\LocalMachine\My',
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$ComputerName,
        [int]$WarningDays = 60,
        [int]$CriticalDays = 30,
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
            $Certificates = Get-CertificateHealth -Computer $ComputerName -Path $Path -WarningDays $WarningDays -CriticalDays $CriticalDays -WarningAlgorithm $WarningAlgorithm -CriticalAlgorithm $CriticalAlgorithm -CriticalKeySize $CriticalKeySize -WarningKeySize $WarningKeySize -ExcludedThumbprint $ExcludedThumbprint -Recurse:([bool]$Recurse.IsPresent) -ErrorAction Stop
            }
        # Catch all exceptions
        catch {
            Write-Error "Unable to get certificates from $ComputerName."
            }
        # Get certificates whose validity period status or algorithm status is not OK.
        $UnhealthyCertificates = $Certificates | Where-Object -FilterScript {$_.ValidityPeriodStatus -ne 'OK' -or $_.AlgorithmStatus -ne 'OK' -or $_.KeySizeStatus -ne 'OK'}
        $UnhealthyCertificates
    }
    End
    {
    }
}