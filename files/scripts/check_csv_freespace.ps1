<#
.SYNOPSIS
    check your CSV for used/free diskspace
.DESCRIPTION
    check your mounted HyperV-CSV for free/used diskspace and exit with nagios exit codes
    additional the script writes out performance data
.NOTES
    File Name      : check_csv_freespace.ps1
    Author         : DGE
    Prerequisite   : PowerShell V2 or newer
.LINK  
    http://nowhere.com
.EXAMPLE  
    .\check_csv_freespace.ps1 -n csv1-scsi -w 80 -c 90
    Sample Output:  OK - csv1-scsi total: 2047GB, used: 734GB (35%), free: 1313GB (64%) | 'csv1-scsi used_space'=734Gb;1637;1842;0;2047
#>

Param(
    [parameter(Mandatory=$true)]
    [alias("n")]
    $csvname,
    [parameter(Mandatory=$true)]
    [alias("w")]
    $warnlevel,
    [parameter(Mandatory=$true)]
    [alias("c")]
    $critlevel)

$exitcode = 3 # "unknown"

$freespace = Get-WmiObject win32_volume | where-object {$_.Label -eq $csvname} | ForEach-Object {[math]::truncate($_.freespace / 1GB)}
$capacity = Get-WmiObject win32_volume | where-object {$_.Label -eq $csvname} | ForEach-Object {[math]::truncate($_.capacity / 1GB)}
$usedspace = $capacity - $freespace
$warnvalue = [math]::truncate(($capacity / 100) * $warnlevel)
$critvalue = [math]::truncate(($capacity / 100) * $critlevel)
$usedpercent = [math]::truncate(($usedspace / $capacity) * 100)
$freepercent = [math]::truncate(($freespace / $capacity) * 100)

if ($usedpercent -gt $critlevel) {
    $exitcode = 2
    Write-Host "CRITICAL - $csvname total: ${capacity}GB, used: ${usedspace}GB (${usedpercent}%), free: ${freespace}GB (${freepercent}%) | '$csvname used_space'=${usedspace}Gb;$warnvalue;$critvalue;0;$capacity"
}
elseif ($usedpercent -gt $warnlevel) {
    $exitcode = 1
    Write-Host "WARNING - $csvname total: ${capacity}GB, used: ${usedspace}GB (${usedpercent}%), free: ${freespace}GB (${freepercent}%) | '$csvname used_space'=${usedspace}Gb;$warnvalue;$critvalue;0;$capacity"
}
else {
    $exitcode = 0
    Write-Host "OK - $csvname total: ${capacity}GB, used: ${usedspace}GB (${usedpercent}%), free: ${freespace}GB (${freepercent}%) | '$csvname used_space'=${usedspace}Gb;$warnvalue;$critvalue;0;$capacity"
}

exit $exitcode