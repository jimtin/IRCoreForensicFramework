function Copy-WindowsRegistry{
    <#
    .SYNOPSIS
    Copies Windows Registry hive from target endpoints

    .DESCRIPTION
    Copies the Windows Registry hive from target endpoint. Current registry hives targeted outlined below:
    1. HKCR. HKEY_CLASSES_ROOT 
    2. HKCU. HKEY_CURRENT_USER
    3. HKLM. HKEY_LOCAL_MACHINE
    4. HKU. HKEY_USERS
    5. HKEY_CURRENT_CONFIG
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Target,
        [Parameter()][System.Management.Automation.PSCredential]$Credentials,
        [Parameter()][switch]$playbook
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-WindowsRegistry"
        "DateTime" = (Get-Date).ToString()
        "TargetHostName" = $target
    }

    if($playbook){
        $copylog = Invoke-PlaybookCommand -Targets $Target -Credentials $cred -Scriptblock{
            # Set up the output variable
            $Output = @{
                "DateTime" = (Get-Date).ToString()
            }
    
            # Create a registry folder in PerformanceInformation
            $registry = New-Item -Path "C:\PerformanceInformation" -Name "Registry" -ItemType Directory
            $Output.Add("RegistryFolderCreated", $registry)
    
            # Use reg export to get HKCR 
            reg export HKCR C:\PerformanceInformation\Registry\HKCR.reg /y
    
            # Use reg export to get HKCU
            reg export HKCU C:\PerformanceInformation\Registry\HKCU.reg /y
    
            # Use reg export to get HKLM
            reg export HKLM C:\PerformanceInformation\Registry\HKLM.reg /y
    
            # Use reg export to get HKU
            reg export HKU C:\PerformanceInformation\Registry\HKU.reg /y
    
            # Use reg export to get HKCC
            reg export HKCC C:\PerformanceInformation\Registry\HKCC.reg /y
        }
    }else{
        $copylog = Invoke-PlaybookCommand -Targets $target -Scriptblock{
            # Set up the output variable
            $Output = @{
                "DateTime" = (Get-Date).ToString()
            }
    
            # Create a registry folder in PerformanceInformation
            $registry = New-Item -Path "C:\PerformanceInformation" -Name "Registry" -ItemType Directory
            $Output.Add("RegistryFolderCreated", $registry)
    
            # Use reg export to get HKCR 
            reg export HKCR C:\PerformanceInformation\Registry\HKCR.reg /y
    
            # Use reg export to get HKCU
            reg export HKCU C:\PerformanceInformation\Registry\HKCU.reg /y
    
            # Use reg export to get HKLM
            reg export HKLM C:\PerformanceInformation\Registry\HKLM.reg /y
    
            # Use reg export to get HKU
            reg export HKU C:\PerformanceInformation\Registry\HKU.reg /y
    
            # Use reg export to get HKCC
            reg export HKCC C:\PerformanceInformation\Registry\HKCC.reg /y
        }
    }
    
    $outcome.Add("CopyWindowsRegistryOutcome", $copylog)

    # Return outcomes to users
    Write-Output $outcome

}