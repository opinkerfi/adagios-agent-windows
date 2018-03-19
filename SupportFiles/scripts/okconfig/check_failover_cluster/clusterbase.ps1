

if(-not $ClusterBaseIncluded)
{
	$ClusterBaseIncluded

	$UtilityBase = Join-Path -Path $PSScriptRoot -ChildPath 'anutilitybase.ps1'
	if(-not (Test-Path -Path $UtilityBase))
	{
		Write-Host ('Required file {0} not found' -f $UtilityBase)
		exit 3
	}
	. $UtilityBase

	function Get-ANClusterBaseVersion
	{
		New-Object System.Version(1, 1, 1, 0)
	}

	function Get-ANIsClustered
	{
		[bool](Get-WmiObject -Namespace root -Class '__NAMESPACE' -Filter 'Name="MSCluster"')
	}
	Set-Alias -Name ANIsClustered -Value Get-ANIsClustered

	function Get-ANClusterPartitionFromCSVName
	{
		param(
			[Parameter()][String]$CSVName
		)
		Get-CimInstance -Namespace root\MSCluster -Class MSCluster_DiskPartition -Filter ('FileSystem="CSVFS" AND VolumeLabel="{0}"' -f $CSVName)
	}

	function Get-ANCSVFromCSVName
	{
		param(
			[Parameter()][String]$CSVName
		)
		$CSVDiskPartition = Get-ANClusterPartitionFromCSVName -CSVName $CSVName
		if($CSVName)
		{
			Get-CimInstance -Namespace root\MSCluster -Class MSCluster_ClusterSharedVolume -Filter ('VolumeName="{0}"' -f ($CSVDiskPartition.Path -replace '\\', '\\'))
		}
	}

	function Get-ANClusterNodes
	{
		(Get-WmiObject -Namespace root\MSCluster -Class MSCluster_Node).Name
	}
}