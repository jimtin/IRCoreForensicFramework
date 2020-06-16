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
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )
    
    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-WindowsRegistryFiles"
        "DateTime" = (Get-Date).ToString()
        "TargetEndpoint" = $Target
    }

    # Assisting in making this parallel by ensuring this command can only implement one target at a time. Parallelization can be done at a more abstract level
    
    # Get the session associated with the Target
    $session = Get-PSSession | Where-Object {$_.ComputerName -eq $Target}

    # Set up the location where artifacts will be extracted to
    $location = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts"

    # Copy the folder across, including recursive files
    $copyitem = Copy-Item -FromSession $session -Path "C:\PerformanceInformation\Registry" -Recurse -Destination $location

    # Add the outcome to the outcome variable
    $outcome.Add("CopyInformation", $copyitem)

    # Return outcome to the user
    Write-Output $outcome
    
}