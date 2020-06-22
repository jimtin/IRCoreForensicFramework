function Invoke-GetRemoteEventLogsandSRU {
    <#
    .SYNOPSIS
    Gets remote event logs folder and SRU, then copies them to this endpoint

    .DESCRIPTION
    1. Copies remote event logs and SRU - Copy-RemoteEventLogging
    2. Extracts them to this endpoing - Get-RemoteEventLogging

    #>
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome
    $outcome = @{
        "HostHunterObject" = "Invoke-GetRemoteEventLogsandSRU"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Copy the event logs
    $copylogs = Copy-RemoteEventLogging -Target $Target
    $outcome.Add("EventLogCopy", $copylogs)

    # Get the event logs and SRU database
    $logextraction = Get-RemoteEventLogging -Target $Target
    $outcome.Add("EventLogExtraction", $logextraction)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return the outcome to the user
    Write-Output $outcome
}