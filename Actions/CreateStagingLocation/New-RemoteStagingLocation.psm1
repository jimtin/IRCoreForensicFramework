function New-RemoteStagingLocation{
    <#
    .SYNOPSIS
    Creates a new folder on remote endpoint(s) to stage the data being gathered

    .DESCRIPTION
    Creates a new folder on the remote endpoint(s). This is used to stage the data to be extracted.
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$TargetList
    )

    # Set up outcome variable
    $outcome = @{
        "StagingLocation" = "C:\PerformanceInformation"
    }

    # Test the endpoint to see if the Performance Information folder exists
    $pathexists = Invoke-Command -Session $Session -ScriptBlock{Test-Path -Path "C:\PerformanceInformation"}
    $outcome.Add("TestedEndpointTimestamp", (Get-Date).ToString())
    if ($pathexists -eq $false){
        Write-Information -InformationAction Continue -MessageData "Creating remote staging location"
        # Create the folder on the endpoint to place WinPMEM
        Invoke-Command -Session $Session -ScriptBlock{New-Item -Path "C:\" -Name "PerformanceInformation" -ItemType "directory"}
        $outcome.Add("CreatedPerformanceInformationFolderTimestamp", (Get-Date).ToString())
        $outcome.Add("Result", "Created")
    }else{
        Write-Information -InformationAction Continue -MessageData "Endpoint path exists, continuing"
        $outcome.Add("Result", "AlreadyCreated")
    }
    Write-Output $outcome
}