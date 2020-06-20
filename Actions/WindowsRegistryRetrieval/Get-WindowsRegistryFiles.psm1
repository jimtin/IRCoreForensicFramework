function Get-WindowsRegistryFiles {
    <#
    .SYNOPSIS
    Gets the Registry files dumped by Copy-WindowsRegistry command

    .DESCRIPTION
    Copies the following Windows Registry hives from remote endpoint https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry
    1. HKCR. HKEY_CLASSES_ROOT 
    2. HKCU. HKEY_CURRENT_USER
    3. HKLM. HKEY_LOCAL_MACHINE
    4. HKU. HKEY_USERS
    5. HKEY_CURRENT_CONFIG

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )
    
    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-WindowsRegistryFiles"
        "DateTime" = (Get-Date).ToString()
        "TargetEndpoint" = $Target
    }

    # Get the HostName from the session
    $hostname = $target.ComputerName
    
    # Set up the location where artifacts will be extracted to
    $location = "C:\ExtractionDirectory\" + $hostname + "_ForensicArtifacts"

    # Copy the folder across, including recursive files
    $copyitem = Copy-Item -FromSession $Target -Path "C:\PerformanceInformation\Registry" -Recurse -Destination $location

    # Check for a range of Registry Artefacts being successfully extracted
    $reglocation = $location + "\Registry"

    # Check for registry folder
    $regfolder = Test-Path -Path $reglocation
    $outcome.Add("RegistryFolder", $regfolder)

    # Check for software hive
    $softwarehivelocation = $reglocation + "\HKLM.reg"
    $softwarehive = Test-Path -Path $softwarehivelocation
    $outcome.Add("SoftwareRegistryHive", $softwarehive)

    # Add the outcome to the outcome variable
    $outcome.Add("CopyInformation", $copyitem)

    # Return outcome to the user
    Write-Output $outcome
    
}