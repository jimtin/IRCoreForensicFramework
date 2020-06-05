function New-LocalDataStagingLocation{
    <#
    .SYNOPSIS
    Creates the local data staging location

    .DESCRIPTION
    Creates the local data staging location 
    #>

    # Check if the staging location exists
    $staginglocation = Test-Path -Path "C:\ExtractionDirectory"

    if($staginglocation -ne $true){
        Write-ColoredInformation -MessageData "Creating local data staging location" -ForegroundColor "Cyan"
        New-Item -Path C:\ -Name "ExtractionDirectory" -ItemType "directory"
    }
}