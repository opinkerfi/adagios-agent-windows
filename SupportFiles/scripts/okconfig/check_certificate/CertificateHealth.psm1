# Source all ps1 scripts in current directory.
Get-ChildItem (Join-Path $PSScriptRoot *.ps1) | foreach {. $_.FullName}

<# Making Parent Functions Available
Export-ModuleMember -Function Get-CertificateFile
Export-ModuleMember -Function Get-CertificateHealth
Export-ModuleMember -Function Get-UnhealthyCertificate
Export-ModuleMember -Function Get-UnhealthyCertificateNagios
#>

<# Get Excluded certificate thumbprints if present
 If you have a list of certificate thumbprints you want to exclude from the checks
 put them in a ExcludedThumbprint.txt in the root of the module. Format of the
 text file is one thumbprint per line.
 The variable is scoped globally so that it can be used with various functions
 in the module. Specify the variable by name $ExcludedThumbprint when calling
 the functions.
 
 Example:
 Get-UnhealthyCertificate -ExcludedThumbprint $ExcludedThumbprint
#>

$ExcludedThumbprintFilePath = "$PSScriptRoot\ExcludedThumbprint.txt"
if (Test-Path $ExcludedThumbprintFilePath) {
    
    # Exporting variable to global scope to be used with module.
    $global:ExcludedThumbprint = Get-Content -Path $ExcludedThumbprintFilePath
    
    # Setting default parameter.
    if ($PSVersionTable.PSVersion.Major -ge 3) {
        $PSDefaultParameterValues.remove("*:ExcludedThumbprint")
        $PSDefaultParameterValues.Add("Get-UnhealthyCertificate:ExcludedThumbprint",$ExcludedThumbprint)
        }
    }