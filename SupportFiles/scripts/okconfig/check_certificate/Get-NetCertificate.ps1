<#
.Synopsis
Get the TLS certificate from a remote server.
.DESCRIPTION
Obtain the TLS certificate from a remote server by name or IP address and TCP port.
.PARAMETER ComputerName
Specify the DNS name or IP address of the URL you want to query.
.PARAMETER Port
Specify the port of the destination server.
.EXAMPLE
Get-NetCertificate -ComputerName www.google.com -Port 443
.EXAMPLE
Get-NetCertificate -IP 8.8.8.8 -Port 853
.NOTES
Adapted by: Jason Wasser
Original code by: Rob VandenBrink
Inspiration
https://isc.sans.edu/forums/diary/Assessing+Remote+Certificates+with+Powershell/20645/

Modified: 1/9/2020 02:16:05 PM 
# Need to verify if this supports server name indication (SNI) for certificates
#>
function Get-NetCertificate {
    Param (
        [Alias('IP')]
        [string]$ComputerName,
        [int]$Port=443
    )

    $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
    try {
        $TcpSocket = New-Object Net.Sockets.TcpClient($ComputerName, $Port)
        $tcpstream = $TcpSocket.GetStream()
        $Callback = { param($sender, $cert, $chain, $errors) return $true }
        $SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)
        try {
            $SSLStream.AuthenticateAsClient($ComputerName)
            $Certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($SSLStream.RemoteCertificate)
        }
        finally {
            $SSLStream.Dispose()
        }
    }
    finally {
        $TCPClient.Dispose()
    }
    Write-Output $Certificate
}