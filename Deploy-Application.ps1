<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
    powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
    Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	Toolkit Exit Code Ranges:
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'MySolutions NORDIC'
	[string]$appName = 'NSCP'
	[string]$appVersion = '0.5.2.35'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.3'
	[string]$appScriptDate = '23/01/2019'
	[string]$appScriptAuthor = 'Gardar Thorsteinsson<gardart@gmail.com>'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = 'NSClient++ Deployment'
	[string]$installTitle = ''
	[version]$AdagiosRelease = [version]'1.0.3'
	## Variables: System architecture detection
	#If([IntPtr]::Size -eq 8)
	#{
		#64bit
	#	[string]$appArch = 'x64'
	#}
	#Else
	#{
		#32bit
	#	[string]$appArch = 'Win32'
	#}
		
	##* Do not modify section below
	#region DoNotModify
	
	## Variables: Exit Code
	[int32]$mainExitCode = 0
	
	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.6.9'
	[string]$deployAppScriptDate = '02/12/2017'
	[hashtable]$deployAppScriptParameters = $psBoundParameters
	
	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'
		
        ## Stop NSClient++ service (nscp) before installing
        #Stop-ServiceAndDependencies -Name 'nscp'
		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		#Show-InstallationWelcome -CloseApps 'nscp' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt
        Show-InstallationWelcome -CloseApps 'nscp' -CheckDiskSpace -Silent
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		#Show-InstallationProgress -StatusMessage "Uppsetning á $appVendor $appname $appVersion. Vinsamlegast bíðið."
		
		## <Perform Pre-Installation tasks here>
		
		## Uninstall older versions of NSClient++ (version 0.3.x) by uninstalling the service
		#Execute-Process -Path "$envProgramFiles\NSClient++\nscp.exe" -Parameters 'service --uninstall --name NSClientpp' -WindowStyle 'Hidden' -ContinueOnError $true
        Test-ServiceExists -Name 'NSClientpp' -PassThru | Where-Object {$_ } | ForEach-Object {$_.Delete() }
        #Test-ServiceExists -Name 'nscp' -PassThru | Where-Object {$_ } | ForEach-Object {$_.Delete() }
        

		# If((Get-RegistryKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{33F14A86-E280-49DD-B3A2-FCD4EEF47F2F}" -Value DisplayVersion) -lt "0.5.2035"){
		# 	Write-Log -Source $deployAppScriptFriendlyName -Message "Current version is too old, removing old MSI versions..."
		# 	Remove-MSIApplications -Name 'NSClient++ (x64)'
		# }
		# else{
		# 	Write-Log -Source $deployAppScriptFriendlyName -Message "This version is the current one, will not remove..."  
		# }

        ## Remove all MSI versions of NSClient++
        Remove-MSIApplications -Name 'NSClient++ (x64)'
        ## Remove 0.5.2033
        Execute-MSI -Action Uninstall -Path '{B5C2D99D-F84E-4BDB-89CE-702A4E57DE95}'
        ## Remove 0.4.4.23
        Execute-MSI -Action Uninstall -Path '{5160016F-E401-432C-9423-A58E18452D52}'
		
		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'
		
		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}
		
		## <Perform Installation tasks here>
		
		If ($Is64Bit) {
			# If((Get-RegistryKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{33F14A86-E280-49DD-B3A2-FCD4EEF47F2F}" -Value DisplayVersion) -lt "0.5.2035"){
            #     Write-Log -Source $deployAppScriptFriendlyName -Message "Current version is too old, installing"
            #     Execute-MSI -Action Install -Path 'NSCP-0.5.2.35-x64.msi' -Parameters '/quiet /norestart ADDLOCAL=ALL REMOVE=Documentation,NSCPlugins,NSCAPlugin,WEBPlugins,OP5Montoring'
            # }
            # else{
            #     Write-Log -Source $deployAppScriptFriendlyName -Message "No need to update..."  
            # }
			Execute-MSI -Action Install -Path 'NSCP-0.5.2.35-x64.msi' -Parameters '/quiet /norestart ADDLOCAL=ALL REMOVE=Documentation,NSCPlugins,NSCAPlugin,WEBPlugins,OP5Montoring'
		}
		Else {
			Execute-MSI -Action Install -Path 'NSCP-0.5.2.35-Win32.msi' -Parameters '/quiet /norestart ADDDEFAULT=ALL REMOVE=Documentation,NSCPlugins,NSCAPlugin,WEBPlugins'
		}
		
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'
		
		## <Perform Post-Installation tasks here>
		if((Get-RegistryKey "HKLM:\SOFTWARE\OpinKerfi\Adagios" -Value CurrentVersion) -lt $AdagiosRelease) {
			Write-Log -Source $deployAppScriptFriendlyName -Message "Adagios OKconfig templates are < [string]$AdagiosRelease, installing"
			Stop-ServiceAndDependencies -Name 'nscp'
			Copy-File -Path "$dirSupportFiles\*.*" -Destination "$envProgramFiles\NSClient++\"
			Copy-File -Path "$dirSupportFiles\Scripts" -Destination "$envProgramFiles\NSClient++" -Recurse
	
			# Update registry key for Adagios agent version (OKconfig version)
			Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\OpinKerfi\Adagios' -Name 'CurrentVersion' -Value $AdagiosRelease -Type String -ContinueOnError:$True
			Start-ServiceAndDependencies -Name 'nscp'
	
		}
  		
		## Display a message at the end of the install
		If (-not $useDefaultMsi) { Show-InstallationPrompt -Message 'Installation completed successfully. Remember to add the ip address of your Nagios server to the "allowed hosts" variable located in the file $envProgramFiles\NSClient++\allowed_hosts.ini. At last, restart the NSClient++ service.' -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Uninstallation tasks here>
		
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		
		# <Perform Uninstallation tasks here>
		
		# Uninstall 0.3.x
		# Uninstall 0.4.x
		# Uninstall 0.5.x

		# Show Progress Message (with a message to indicate the application is being uninstalled)
		Show-InstallationProgress -StatusMessage 'Uninstalling Application $installTitle. Please Wait...'
		# Remove this version of Adobe Reader
		#Execute-MSI -Action Uninstall -Path '{AC76BA86-7AD7-1033-7B44-AB0000000001}'

		
		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		
		## <Perform Post-Uninstallation tasks here>
		
		
	}
	
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================
	
	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}