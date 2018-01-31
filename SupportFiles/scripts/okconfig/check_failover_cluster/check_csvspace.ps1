<#
	check_csvspace.ps1
	Written by Eric Siron
	(c) Altaro Software 2017
 
	Version 1.2 November 19, 2017
 
	Intended for use with the NSClient++ module from http://nsclient.org
	Checks a Cluster Shared Volume's available space and returns the status to Nagios.
#>
 
param(
	[Parameter(Position = 1)][String]$CSVName,
	[Parameter(Position = 2)][UInt16]$WarningLevel,
	[Parameter(Position = 3)][UInt16]$CriticalLevel
)
 
if ([String]::IsNullOrEmpty($CSVName))
{
	Write-Host -Object 'No CSV was specified'
	Exit 3
}

 
$ClusterBase = Join-Path -Path $PSScriptRoot -ChildPath 'clusterbase.ps1'
. $ClusterBase
 
$CSVPartition = Get-ANClusterPartitionFromCSVName -CSVName $CSVName
 
if ($CSVPartition)
{
	if($WarningLevel -gt 100) { $WarningLevel = 100 }
	if($CriticalLevel -gt 100) { $CriticalLevel = 100 }
	$TotalSpace = $CSVPartition.TotalSize
	$FreeSpace = $CSVPartition.FreeSpace
	$FreePercent = $FreeSpace / $TotalSpace * 100
	$UsedSpace = $TotalSpace - $FreeSpace
	Write-Host -Object ('{0}MB free. {1}MB total. {2:N0}% free.|''CSV Used Space''={3}mb;{4};{5};;' -f $FreeSpace, $TotalSpace, $FreePercent, $UsedSpace, [uint32]($TotalSpace * $WarningLevel / 100), [uint32]($TotalSpace * $CriticalLevel / 100))
	if ($FreePercent -le (100 - $CriticalLevel))
	{
		exit 2
	}
	if ($FreePercent -le (100 - $WarningLevel))
	{
		exit 1
	}
}
else
{
	Write-Host -Object ('No CSV named {0} found.' -f $CSVName)
	exit 3
}
exit 0