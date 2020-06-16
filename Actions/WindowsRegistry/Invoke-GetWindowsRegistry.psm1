function Invoke-GetWindowsRegistry{
    <#
    .SYNOPSIS
    Combines the Copy-WindowsRegistryFiles and Get-WindowsRegistryFiles cmdlets together to enable Incident Responder to get registry files from specified target

    .DESCRIPTION
    Combines the Copy-WindowsRegistry and Get-WindowsRegistryFiles cmdlets together to enable Incident Responder to get registry files from specified target

    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )

    # Set up the output variable
    $output = @{
        "HostHunterObject" = "Invoke-GetWindowsRegistry"
        "DateTime" = (Get-Date).ToString()
        "TargetHostName" = $Target
    }

    # Copy the registry files, add the output to the output variable
    $copyfiles = Copy-WindowsRegistry -Target $Target
    $output.Add("CopyWindowsRegistryFiles", $copyfiles)

    # Extract the registry files to target endpoint and add the results to the output variable
    $getfiles = Get-WindowsRegistryFiles -Target $Target
    $output.Add("GetWindowsRegistryFiles", $getfiles)

    # Return the output to the user
    Write-Output $output

}