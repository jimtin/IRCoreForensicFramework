function New-ProcessedArtefactsStagingLocation {
    <#
    .SYNOPSIS
    Creates the folder to store current state information

    .DESCRIPTION
    Creates the folder to store current state information

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )

    # Create the outcome directory
    $outcome = @{
        "HostHunterObject" = "New-ProcessedArtefactsStagingLocation"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Create the location variable
    $path = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts"
    $fullpath = $path + "\ProcessedArtefacts"
    $outcome.Add("DirectoryLocation", $fullpath)

    # Test if the path exists. If not, create
    $ispath = Test-Path -Path $fullpath 
    if($ispath -ne $true){
        $createdpath = New-Item -Path $path -ItemType Directory -Name "ProcessedArtefacts"
        $outcome.Add("NewPathCreated", $createdpath)
    }
    
}