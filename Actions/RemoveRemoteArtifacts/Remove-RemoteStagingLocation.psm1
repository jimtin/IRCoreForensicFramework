function Remove-RemoteStagingLocation{
    <#
    .SYNOPSIS
    Removes the remote staging location from remote endpoint(s)

    .DESCRIPTION
    Removes the remote staging location from remote endpoint(s)
    Pairs with New-RemoteStagingLocation module
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Remove-RemoteStagingLocation"
        "StagingLocation" = "C:\PerformanceInformation"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $pathexists = Invoke-HostHunterCommand -Target $Target -ScriptBlock{
        # Set up output dictionary
        $output = @{}
        # Get Hostname of the command being run
        $output.Add("HostName", $env:COMPUTERNAME)
        # Test for the path
        $outcome = Test-Path -Path "C:\PerformanceInformation"
        # If outcome is true, remove the directory
        if($outcome -eq $true){
            $output.Add("RemovedPerformanceInformationFolderTimestamp", (Get-Date).ToString())
            Remove-Item -Path "C:\PerformanceInformation" -Recurse
        }
        # Record outcome for posterity
        $output.Add("Outcome", $outcome)
        Write-Output $output
    }

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    

    # Add the results to outcome dictionary
    $outcome.Add("EndpointOutcomes", $pathexists)
    
    # Return results to pwsh
    Write-Output $outcome
}