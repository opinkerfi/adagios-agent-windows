<#
.Synopsis
Show the TLS certificate from a remote server as a certificate file.
.DESCRIPTION
Obtain the TLS certificate from a remote server by name or IP address and TCP port and save it to disk.
.EXAMPLE
Save-NetCertificate -ComputerName www.google.com -Port 443 -Path C:\Temp\server.crt
.EXAMPLE
Save-NetCertificate -IP 8.8.8.8 -Port 853 -Path C:\Temp\server.crt
.NOTES
Adapted by: Jason Wasser
Original code by: Rob VandenBrink
Inspiration
https://isc.sans.edu/forums/diary/Assessing+Remote+Certificates+with+Powershell/20645/
Modified: 1/9/2020 02:16:05 PM 
#>
function Get-NetCertificateHealth {
    Param (
        [Alias('IP')]
        $ComputerName,
        [int]$Port = 443,
        [int]$WarningDays = 60,
        [int]$CriticalDays = 30,
        [string[]]$WarningAlgorithm = ('sha1RSA'),
        [string[]]$CriticalAlgorithm = ('md5RSA'),
        [int]$CriticalKeySize = 1024,
        [int]$WarningKeySize = 2048
    )

    $NetCertificate = Get-NetCertificate -ComputerName $ComputerName -Port $Port
    $CertificateProperties = @{
        ComputerName       = $ComputerName + ':' + $Port
        FileName           = 'N/A'
        Subject            = $NetCertificate.Subject
        SignatureAlgorithm = $NetCertificate.SignatureAlgorithm.FriendlyName
        NotBefore          = $NetCertificate.NotBefore
        NotAfter           = $NetCertificate.NotAfter
        Days               = ($NetCertificate.NotAfter - (Get-Date)).Days
        Thumbprint         = $NetCertificate.Thumbprint
        KeySize            = $NetCertificate.PublicKey.Key.KeySize
    }
    $Certificate = New-Object -TypeName PSObject -Property $CertificateProperties

    #region Check certificate expiration
                    
    # Check certificate is within $WarningDays
    if ($Certificate.NotAfter -le (Get-Date).AddDays($WarningDays) -and $Certificate.NotAfter -gt (Get-Date).AddDays($CriticalDays)) {
        Write-Verbose "Certificate is expiring within $WarningDays days."
        $ValidityPeriodStatus = 'Warning'
        $ValidityPeriodStatusMessage = "Certificate expiring in $($Certificate.Days) days."
    }
    # Check certificate is within $CriticalDays
    elseif ($Certificate.NotAfter -le (Get-Date).AddDays($CriticalDays) -and $Certificate.NotAfter -gt (Get-Date)) {
        Write-Verbose "Certificate is expiring within $CriticalDays days."
        $ValidityPeriodStatus = 'Critical'
        $ValidityPeriodStatusMessage = "Certificate expiring in $($Certificate.Days) days."
    }
    # Check certificate is expired
    elseif ($Certificate.NotAfter -le (Get-Date)) {
        Write-Verbose "Certificate is expiring within $CriticalDays"
        $ValidityPeriodStatus = 'Critical'
        $ValidityPeriodStatusMessage = "Certificate expired: $($Certificate.Days) days."
    }
    # Certificate validity period is healthy.
    else {
        Write-Verbose "Certificate is within validity period."
        $ValidityPeriodStatus = 'OK'
        $ValidityPeriodStatusMessage = "Certificate expires in $($Certificate.Days) days."
    }
    #endregion

    #region Check certificate algorithm
    if ($CriticalAlgorithm -contains $Certificate.SignatureAlgorithm) {
        Write-Verbose "Certificate uses critical algorithm."
        $AlgorithmStatus = 'Critical'
        $AlgorithmStatusMessage = "Certificate uses a vulnerable algorithm $($Certificate.SignatureAlgorithm)."
    }
    elseif ($WarningAlgorithm -contains $Certificate.SignatureAlgorithm) {
        Write-Verbose "Certificate uses warning algorithm."
        $AlgorithmStatus = 'Warning'
        $AlgorithmStatusMessage = "Certificate uses the deprecated algorithm $($Certificate.SignatureAlgorithm)."
    }
    else {
        Write-Verbose "Certificate uses acceptable algorithm."
        $AlgorithmStatus = 'OK'
        $AlgorithmStatusMessage = "Certificate uses valid algorithm $($Certificate.SignatureAlgorithm)."
    }
    #endregion

    #region Check MinimumKeySize
    Write-Verbose 'Checking minimum key length.'
    if ($Certificate.KeySize -lt $CriticalKeySize) {
        # Key Size is critical
        Write-Verbose 'Certificate key length is critical.'
        $KeySizeStatus = 'Critical'
        $KeySizeStatusMessage = "Certificate key size $($Certificate.KeySize) is less than $CriticalKeySize."
    }
    elseif ($Certificate.KeySize -lt $WarningKeySize -and $Certificate.KeySize -ge $CriticalKeySize) {
        # Key Size is warning
        Write-Verbose 'Certificate key length is warning.'
        $KeySizeStatus = 'Warning'
        $KeySizeStatusMessage = "Certificate key size $($Certificate.KeySize) is less than $WarningKeySize."
    }
    elseif ($Certificate.KeySize -ge $WarningKeySize) {
        # Key Size is OK
        Write-Verbose 'Certificate key length is OK.'
        $KeySizeStatus = 'OK'
        $KeySizeStatusMessage = "Certificate key size $($Certificate.KeySize) is greater than or equal to $WarningKeySize."
    }
    else {
        # Key Size is OK
        Write-Verbose 'Certificate key length is Unknown.'
        $KeySizeStatus = 'Unknown'
        $KeySizeStatusMessage = "Certificate key size is unknown."
    }
    #endregion
    Write-Verbose 'Adding additional properties to the certificate object.'
    $CertificateProperties = [ordered]@{
        ComputerName                = $ComputerName + ':' + $Port
        FileName = $Certificate.FileName
        Subject                     = $Certificate.Subject
        SignatureAlgorithm          = $Certificate.SignatureAlgorithm
        NotBefore                   = $Certificate.NotBefore
        NotAfter                    = $Certificate.NotAfter
        Days                        = $Certificate.Days
        Thumbprint                  = $Certificate.Thumbprint
        ValidityPeriodStatus        = $ValidityPeriodStatus
        ValidityPeriodStatusMessage = $ValidityPeriodStatusMessage
        AlgorithmStatus             = $AlgorithmStatus
        AlgorithmStatusMessage      = $AlgorithmStatusMessage
        KeySize                     = $Certificate.KeySize
        KeySizeStatus               = $KeySizeStatus
        KeySizeStatusMessage        = $KeySizeStatusMessage
    }
    $Certificate = New-Object -TypeName PSObject -Property $CertificateProperties
    $Certificate
}