function New-CurrentStateStagingLocation {
    <#
    .SYNOPSIS
    Creates the folder to store current state information

    .DESCRIPTION
    Creates the folder to store current state information

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Create the outcome directory
    $outcome = @{
        "HostHunterObject" = "New-CurrentStateStagingLocation"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Create the location variable
    $path = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts"
    $fullpath = $path + "\CurrentStateInformation"
    $outcome.Add("DirectoryLocation", $fullpath)

    # Test if the path exists. If not, create
    $ispath = Test-Path -Path $fullpath 
    if($ispath -ne $true){
        $createdpath = New-Item -Path $path -ItemType Directory -Name "CurrentStateInformation"
        $outcome.Add("NewPathCreated", $createdpath)
    }
    
}