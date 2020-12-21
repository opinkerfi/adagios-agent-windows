<#
.Synopsis
Test the SSL and TLS protocols on a remote server.
.DESCRIPTION
Validate which SSL and TLS protocols are enabled or disabled on remote systems and ports.
.PARAMETER ComputerName
Specify the DNS name or IP address of the URL you want to query.
.PARAMETER Port
Specify the port of the destination server.
.EXAMPLE
Test-NetSslProtocol -ComputerName www.google.com -Port 443
.EXAMPLE
Test-NetSslProtocol -IP 8.8.8.8 -Port 853
.NOTES
Created by: Jason Wasser
Modified: 4/3/2020
#>

function Test-NetSslProtocol {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('IP')]
        [string[]]$ComputerName,
        [int[]]$Port = 443,
        [ValidateSet('ssl2', 'ssl3', 'tls', 'tls11', 'tls12', 'tls13')]
        [string[]]$Protocol = ('ssl2', 'ssl3', 'tls', 'tls11', 'tls12', 'tls13')
    )
    begin {
        $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
    }
    process {
        foreach ($Computer in $ComputerName) {
            foreach ($CurrentPort in $Port) {
                foreach ($CurrentProtocol in $Protocol) {
                    Write-Verbose "Testing $CurrentProtocol on ${Computer}:$Port"
                    try {
                        $TcpSocket = New-Object Net.Sockets.TcpClient($Computer, $CurrentPort)
                        $tcpstream = $TcpSocket.GetStream()
                        $Callback = { param($sender, $cert, $chain, $errors) return $true }
                        $SSLStream = New-Object -TypeName System.Net.Security.SSLStream -ArgumentList @($tcpstream, $True, $Callback)
                        try {
                            $SSLStream.AuthenticateAsClient($Computer, $null, $CurrentProtocol, $false)
                            $ProtocolStatus = 'Enabled'
                        }
                        catch {
                            $ProtocolStatus = 'Disabled'
                        }
                        finally {
                            $SSLStream.Dispose()
                        }
                    }
                    catch {
                        Write-Warning "Unable to connect to ${Computer}:$CurrentPort"
                        break
                    }
                    finally {
                        $TCPClient.Dispose()
                    }
                    if ($ProtocolStatus) {
                        $NetSslProtocolProperties = [ordered]@{
                            ComputerName   = $Computer
                            Port           = $CurrentPort
                            Protocol       = $CurrentProtocol
                            ProtocolStatus = $ProtocolStatus
                        }
                        $NetSslProtocol = New-Object -TypeName PSCustomObject -Property $NetSslProtocolProperties
                        Write-Output $NetSslProtocol
                        $ProtocolStatus = $null
                    }
                }
            }
        }   
    }
    end { }
}