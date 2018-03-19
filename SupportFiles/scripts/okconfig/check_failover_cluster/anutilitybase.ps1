<#
	anutilitybase.ps1
	Written by Eric Siron
	(c) Altaro Software 2017
 
	Version 1.0 May 17th, 2017
 
	Intended for use with the NSClient++ module from http://nsclient.org
	Provides reusable functions for other check scripts.
#>
if(-not $ANUtilityBaseIncluded)
{
	$ANUtilityBaseIncluded = $true
 
	function Get-ANUtilityBaseVersion
	{
		New-Object System.Version(1, 0, 0, 0)
	}
 
	function Format-ANStorageNumberAsFriendly
	{
		param(
			[Parameter(Position=1)][UInt64]$Number,
			[Parameter(Position=2)][Switch]$AsBits
		)
	 
		$DigitLength = $Number.ToString().Length
		$DigitGrouping = [Math]::Floor($DigitLength / 3)
		$DigitGroupLocatorModulus = $DigitLength % 3
		if($DigitGrouping -gt 0 -and -$DigitGroupLocatorModulus -eq 0)
		{
			$DigitGrouping -= 1
		}
		if($AsBits)
		{
			$Tag = 'b'
		}
		else
		{
			$Tag = 'B'
		}
 
		switch($DigitGrouping)
		{
			0 { $ShortenedNumber = $Number; $Suffix = ''	}
			1 { $ShortenedNumber = $Number / 1KB; $Suffix = 'K' }
			2 { $ShortenedNumber = $Number / 1MB; $Suffix = 'M' }
			3 { $ShortenedNumber = $Number / 1GB; $Suffix = 'G' }
			4 { $ShortenedNumber = $Number / 1TB; $Suffix = 'T' }
			default { $ShortenedNumber = $Number / 1PB; $Suffix = 'P' }
		}
		'{0:N2} {1}{2}' -f $ShortenedNumber, $Suffix, $Tag
	}
 
	function Format-ANNumberAsPercent
	{
		param([Parameter(Position=1)]$Number)
		'{0:N2}%' -f ($Number * 100)
	}
 
	function Get-ANIsClustered
	{
		[bool](Get-WmiObject -Namespace root -Class '__NAMESPACE' -Filter 'Name="MSCluster"')
	}
	Set-Alias -Name ANIsClustered -Value Get-ANIsClustered
}