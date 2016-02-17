On Error Resume Next
Const ForReading = 1
Const ForWriting = 1
set objNetwork = wscript.createobject("wscript.network")
set objShell   = wscript.createobject("wscript.shell")
set objEnv = objShell.Environment("PROCESS")
objEnv("SEE_MASK_NOZONECHECKS") = 1
set objFso = Wscript.CreateObject("Scripting.FileSystemObject")

UserName = objNetwork.UserName
ComputerName = objNetwork.ComputerName
v_CurrentDir = Replace(WScript.ScriptFullName,WScript.ScriptName,"")
v_AllUsersPath = objShell.SpecialFolders("AllUsersDesktop")
v_SystemArchitecture = objShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\PROCESSOR_ARCHITECTURE")
v_UserProfile = objShell.ExpandEnvironmentStrings("%USERPROFILE%") 
v_AllUsersStartMenuPath = objShell.ExpandEnvironmentStrings("%ProgramData%")

if len(v_AllUsersStartMenuPath) < 2 then
	v_AllUsersStartMenuPath = "C:\Documents and Settings\All Users\Start Menu\Programs"
Else 
	v_AllUsersStartMenuPath = v_AllUsersStartMenuPath &"\Microsoft\Windows\Start Menu\Programs\"
end if

Set objSWbemServices = GetObject("winmgmts:\\" & ComputerName & "\root\cimv2")
err.clear
Set colSWbemObjectSet = objSWbemServices.ExecQuery("SELECT * FROM Win32_ComputerSystem")
'For Each objSWbemObject In colSWbemObjectSet	
'Next

If v_SystemArchitecture = "x86" Then
	v_SystemArchitecture = "Win32"
Else
	v_SystemArchitecture = "x64" 
End if

'Uppsetningar stillingar
v_ProgramName = "Nagios Client 0.4.4.15"
v_ProgramCount = 4 ' Number of programs/scripts to run

dim ObjectPath()
dim ObjectSetupName()
dim ObjectParameter()
dim ObjectIntReturn()

redim ObjectIntReturn(v_ProgramCount)
redim ObjectPath(v_ProgramCount)
redim ObjectSetupName(v_ProgramCount)
redim ObjectParameter(v_ProgramCount)

i=0
ObjectPath(i) = ""
ObjectSetupName(i) = "%programfiles%\NSClient++\nscp.exe"
ObjectParameter(i) = " service --stop"
strCommand = chr(34) & ObjectPath(i) & ObjectSetupName(i) & chr(34) & ObjectParameter(i)
'msgbox strCommand
ObjectIntReturn(i) = objShell.Run (strCommand,0,True)

i=1
ObjectPath(i) = v_CurrentDir
ObjectSetupName(i) = "NSCP-0.4.4.15-" & v_SystemArchitecture & ".msi"
'ObjectParameter(i) = " /QN /norestart ADDLOCAL=ALL REMOVE=Documentation,NSCPlugins,NSCAPlugin MONITORING_TOOL=GENERIC INSTALL_SAMPLE_CONFIG=0 ALLOWED_HOSTS=127.0.0.1,::1 NRPEMODE=LEGACY GENERATE_SAMPLE_CONFIG=0 ALLOW_CONFIGURATION=1"
ObjectParameter(i) = " /quiet /norestart ADDLOCAL=ALL REMOVE=Documentation,NSCPlugins,NSCAPlugin,SampleScripts,OP5Montoring,WEBPlugins"
strCommand = "Msiexec.exe /i " & chr(34) & ObjectPath(i) & ObjectSetupName(i) & chr(34)
strCommand = StrCommand & ObjectParameter(i) & " /l* " & chr(34) & TempDir & "setup.log" & chr(34)
'msgbox strCommand
ObjectIntReturn(i) = objShell.Run (strCommand,0,True)

i=2
ObjectPath(i) = ""
ObjectSetupName(i) = "xcopy "
ObjectParameter(i) =  Chr(34) & v_CurrentDir & "files\*.*" & Chr(34) & " " & Chr(34) & "%programfiles%\NSClient++\" & Chr(34) & " /e /y"
strCommand = "CMD /C ECHO F | " & ObjectSetupName(i) & ObjectParameter(i)     	
'msgbox strCommand
ObjectIntReturn(i) = objShell.Run (strCommand,0,True)

i=3
ObjectPath(i) = ""
ObjectSetupName(i) = "%programfiles%\NSClient++\nscp.exe"
ObjectParameter(i) = " service --start"
strCommand = chr(34) & ObjectPath(i) & ObjectSetupName(i) & chr(34) & ObjectParameter(i)
'msgbox strCommand
ObjectIntReturn(i) = objShell.Run (strCommand,0,True)

' -----

objEnv.Remove("SEE_MASK_NOZONECHECKS")

Public Function ErrorTranslation(ErrorCodeReturn)
    If ErrorCodeReturn = 0 Then ErrorTranslation = "Installation Successful."  End If
    If ErrorCodeReturn = 1 Then ErrorTranslation = "Incorrect function." End  If 
    If ErrorCodeReturn = 2 Then ErrorTranslation = "The system cannot find the file specified." End If 
    If ErrorCodeReturn = 3 Then ErrorTranslation = "The system cannot find the path specified." End If 
    If ErrorCodeReturn = 4 Then ErrorTranslation = "The system cannot open the file." End If 
    If ErrorCodeReturn = 5 Then ErrorTranslation = "Access is denied." End If 
    If ErrorCodeReturn = 6 Then ErrorTranslation = "The handle is invalid."  End If 
    If ErrorCodeReturn = 7 Then ErrorTranslation = "The storage control blocks  were destroyed." End If 
    If ErrorCodeReturn = 8 Then ErrorTranslation = "Not enough storage is  available to process this command." End If 
    If ErrorCodeReturn = 9 Then ErrorTranslation = "The storage control block  address is invalid." End If 
    If ErrorCodeReturn = 10 Then ErrorTranslation = "The environment is  incorrect." End If 
    If ErrorCodeReturn = 11 Then ErrorTranslation = "An attempt was made to  load a program with an incorrect format." End If 
    If ErrorCodeReturn = 12 Then ErrorTranslation = "The access code is  invalid." End If 
    If ErrorCodeReturn = 13 Then ErrorTranslation = "The data is invalid." End  If 
    If ErrorCodeReturn = 14 Then ErrorTranslation = "Not enough storage is  available to complete this operation." End If 
    If ErrorCodeReturn = 15 Then ErrorTranslation = "The system cannot find  the drive specified." End If 
    If ErrorCodeReturn = 16 Then ErrorTranslation = "The directory cannot be  removed." End If 
    If ErrorCodeReturn = 17 Then ErrorTranslation = "The system cannot move  the file to a different disk drive." End If 
    If ErrorCodeReturn = 18 Then ErrorTranslation = "There are no more files."  End If 
    If ErrorCodeReturn = 19 Then ErrorTranslation = "The media is write  protected." End If 
    If ErrorCodeReturn = 20 Then ErrorTranslation = "The system cannot find  the device specified." End If 
    If ErrorCodeReturn = 21 Then ErrorTranslation = "The device is not ready."  End If 
    If ErrorCodeReturn = 22 Then ErrorTranslation = "The device does not  recognize the command." End If 
    If ErrorCodeReturn = 23 Then ErrorTranslation = "Data error (cyclic  redundancy check)." End If 
    If ErrorCodeReturn = 24 Then ErrorTranslation = "The program issued a  command but the command length is incorrect." End if	    
    If ErrorCodeReturn = 25 Then ErrorTranslation = "The drive cannot locate a  specific area or track on the disk." End If 
    If ErrorCodeReturn = 1601 Then ErrorTranslation = "The Windows Installer  service could not be accessed." End If 
    If ErrorCodeReturn = 1602 Then ErrorTranslation = "The user cancelled  setup. Installation cannot proceed." End If 
    If ErrorCodeReturn = 1603 Then ErrorTranslation = "Fatal error during  installation (this error is returned if any custom action fails within an MSI- based setup for example)." End If 
    If ErrorCodeReturn = 1604 Then ErrorTranslation = "Installation suspended,  incomplete." End If  
    If ErrorCodeReturn = 1605 Then ErrorTranslation = "This action is only  valid for products that are currently installed." End If 
    If ErrorCodeReturn = 1606 Then ErrorTranslation = "Feature ID not  registered." End If 
    If ErrorCodeReturn = 1607 Then ErrorTranslation = "Component ID not  registered." End If  
    If ErrorCodeReturn = 1608 Then ErrorTranslation = "Unknown property." End  If  
    If ErrorCodeReturn = 1609 Then ErrorTranslation = "Handle is in an invalid  state." End If  
    If ErrorCodeReturn = 1610 Then ErrorTranslation = "The configuration data  for this product is corrupt. Contact your support personnel." End If  
    If ErrorCodeReturn = 1611 Then ErrorTranslation = "Component qualifier not  present." End If  
    If ErrorCodeReturn = 1612 Then ErrorTranslation = "The installation source  for this product is not available. Verify that the source exists and that you  can access it." End If   
    If ErrorCodeReturn = 1613 Then ErrorTranslation = "This installation  package cannot be installed by the Windows Installer service. You must install  a Windows service pack that contains a newer version of the Windows Installer  service." End If  
    If ErrorCodeReturn = 1614 Then ErrorTranslation = "Product is  uninstalled." End If  
    If ErrorCodeReturn = 1615 Then ErrorTranslation = "SQL query syntax  invalid or unsupported." End If  
    If ErrorCodeReturn = 1616 Then ErrorTranslation = "Record field does not  exist." End If  
    If ErrorCodeReturn = 1618 Then ErrorTranslation = "Another installation is  already in progress. Complete that installation before proceeding with this  install." End If  
    If ErrorCodeReturn = 1619 Then ErrorTranslation = "This installation  package could not be opened. Verify that the package exists and that you can  access it, or contact the application vendor to verify that this is a valid  Windows Installer package." End If  
    If ErrorCodeReturn = 1620 Then ErrorTranslation = "This installation  package could not be opened. Contact the application vendor to verify that  this is a valid Windows Installer package." End If 
    If ErrorCodeReturn = 1621 Then ErrorTranslation = "There was an error  starting the Windows Installer service user interface. Contact your support  personnel." End If 
    If ErrorCodeReturn = 1622 Then ErrorTranslation = "Error opening Windows  Installer log file. Verify that the log file location exists and is writable."  End If 
    If ErrorCodeReturn = 1623 Then ErrorTranslation = "This language of this  installation package is not supported by your system." End If 
    If ErrorCodeReturn = 1624 Then ErrorTranslation = "Error applying  transforms. Verify that the specified transform paths are valid." End If 
    If ErrorCodeReturn = 1625 Then ErrorTranslation = "This installation is  forbidden by system policy. Contact your system administrator." End If 
    If ErrorCodeReturn = 1626 Then ErrorTranslation = "Function could not be  executed." End If  
    If ErrorCodeReturn = 1627 Then ErrorTranslation = "Function failed during  execution." End If  
    If ErrorCodeReturn = 1628 Then ErrorTranslation = "Invalid or unknown  table specified." End If  
    If ErrorCodeReturn = 1629 Then ErrorTranslation = "Data supplied is of  wrong type." End If  
    If ErrorCodeReturn = 1630 Then ErrorTranslation = "Data of this type is  not supported." End If  
    If ErrorCodeReturn = 1631 Then ErrorTranslation = "The Windows Installer  service failed to start. Contact your support personnel." End If 
    If ErrorCodeReturn = 1632 Then ErrorTranslation = "The temp folder is  either full or inaccessible. Verify that the temp folder exists and that you  can write to it." End If 
    If ErrorCodeReturn = 1633 Then ErrorTranslation = "This installation  package is not supported on this platform. Contact your application vendor."  End If 
    If ErrorCodeReturn = 1634 Then ErrorTranslation = "Component not used on  this machine" End If  
    If ErrorCodeReturn = 1635 Then ErrorTranslation = "This patch package  could not be opened. Verify that the patch package exists and that you can  access it, or contact the application vendor to verify that this is a valid  Windows Installer patch package." End If 
    If ErrorCodeReturn = 1636 Then ErrorTranslation = "This patch package  could not be opened. Contact the application vendor to verify that this is a  valid Windows Installer patch package." End If 
    If ErrorCodeReturn = 1637 Then ErrorTranslation = "This patch package  cannot be processed by the Windows Installer service. You must install a  Windows service pack that contains a newer version of the Windows Installer  service." End If 
    If ErrorCodeReturn = 1638 Then ErrorTranslation = "Another version of this  product is already installed. Installation of this version cannot continue. To  configure or remove the existing version of this product, use Add/Remove  Programs on the Control Panel." End If 
    If ErrorCodeReturn = 1639 Then ErrorTranslation = "Invalid command line  argument. Consult the Windows Installer SDK for detailed command line help."  End If 
    If ErrorCodeReturn = 1640 Then ErrorTranslation = "Installation from a  Terminal Server client session not permitted for current user." End If 
    If ErrorCodeReturn = 1641 Then ErrorTranslation = "The installer has  started a reboot. This error code not available on Windows Installer version  1.0." End If 
    If ErrorCodeReturn = 1642 Then ErrorTranslation = "The installer cannot  install the upgrade patch because the program being upgraded may be missing or  the upgrade patch updates a different version of the program. Verify that the  program to be upgraded exists on your computer and that you have the correct  upgrade patch. " End If 
    If ErrorCodeReturn = 1643 Then ErrorTranslation = "The patch package is  not permitted by system policy. This error code is available with Windows  Installer versions 2.0 or later." End If 
    If ErrorCodeReturn = 1644 Then ErrorTranslation = "One or more  customizations are not permitted by system policy. This error code is  available with Windows Installer versions 2.0 or later." End If 
    If ErrorCodeReturn = 3010 Then ErrorTranslation = "Installation  Successful, a reboot is required." End If
    If ErrorCodeReturn = 4096 Then ErrorTranslation = "Invalid command line  parameter(s)." End If
    If ErrorCodeReturn = 4097 Then ErrorTranslation = "Administrator  provileges are required to run setup." End If
    If ErrorCodeReturn = 4098 Then ErrorTranslation = "Installation of Windows  Installer failed." End If
    If ErrorCodeReturn = 4099 Then ErrorTranslation = "Windows Installer is  not configured properly on the machine." End If
    If ErrorCodeReturn = 4100 Then ErrorTranslation = "CreateMutex failed."  End If
    If ErrorCodeReturn = 4101 Then ErrorTranslation = "Another instance of  setup is already running." End If
    If ErrorCodeReturn = 4102 Then ErrorTranslation = "Cannot open the MSI  database." End If
    If ErrorCodeReturn = 4103 Then ErrorTranslation = "Cannot read from the  MSI database." End If
    If ErrorCodeReturn = 4111 Then ErrorTranslation = "Cannot retrieve the  %temp% directory." End If
    If ErrorCodeReturn = 4113 Then ErrorTranslation = "Beta components have  been detected on the machine that must be uninstalled before installation can  proceed." End If
    If ErrorCodeReturn = 4115 Then ErrorTranslation = "The length of the  %temp% path is too long." End If
    If ErrorCodeReturn = 4116 Then ErrorTranslation = "The length of the  source path too long." End If
    If ErrorCodeReturn = 4118 Then ErrorTranslation = "Failed to create or  write to the log file." End If
    If ErrorCodeReturn = 4119 Then ErrorTranslation = "The Windows Installer  service is not responding to Service Control requests and the system requires  a reboot in order to continue." End If
    If ErrorCodeReturn = 4120 Then ErrorTranslation = "An internal error  occured while trying to initialize the Windows Installer service." End If 
    If ErrorCodeReturn = 4121 Then ErrorTranslation = "One or more  prerequisites for this product is missing." End If
    If ErrorCodeReturn = 4122 Then ErrorTranslation = "The product does not  support installing on the current operating system type." End If 
    If ErrorCodeReturn = 4123 Then ErrorTranslation = "The product is already  installed as an operating system component." End If 
    If ErrorCodeReturn = 4124 Then ErrorTranslation = "Error processing the  install.ini file (there is either a syntax error or a missing mandatory  entry)." End If 
    If ErrorCodeReturn = 8191 Then ErrorTranslation = "Setup failure - unknown  reason (all errors not covered above are grouped into this bucket)." End If 
    If ErrorCodeReturn = 8192 Then ErrorTranslation = "Reboot is required."  End If
End Function

