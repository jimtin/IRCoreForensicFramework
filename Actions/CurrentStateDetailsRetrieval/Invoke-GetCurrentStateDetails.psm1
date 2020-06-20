function Invoke-GetCurrentStateDetails {
    <#
    .SYNOPSIS
    Gets a collection of current state information

    .DESCRIPTION
    Gets a collection of the current state information

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-GetCurrentStateDetails"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Create the storage directory
    $currentstatedirectory = New-CurrentStateStagingLocation -Target $Target
    $outcome.Add("CreateDirectory", $currentstatedirectory)

    # Get the processes
    $processes = Get-CurrentProcesses -Target $Target
    $outcome.Add("CurrentProcesses", $processes)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add the results to outcome dictionary
    $outcome.Add("EndpointOutcomes", $pathexists)
    
    # Return results to pwsh
    Write-Output $outcome
}