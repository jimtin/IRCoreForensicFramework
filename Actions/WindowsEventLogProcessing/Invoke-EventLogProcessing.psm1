function Invoke-EventLogProcessing {
    <#
    .SYNOPSIS
    Processes all the Event Logs needed for post processing. This is an ever growing list.

    .DESCRIPTION
    Processes all the Event Logs needed for post processing. This is an ever growing list.
    1. ProcessStartEvents

    #>
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )
    
    # Create outcome variable
    $outcome = @{
        "HostHunterObject" = "Export-ProcessStartEvents"
        "DateTimeCreated" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Process process start logs
    $processstart = Export-ProcessStartEvents -Target $Target
    $outcome.Add("ProcessStartLogs", $processstart)

    # Process process stop logs
    $processstop = Export-ProcessStopEvents -Target $Target
    $outcome.Add("ProcessStopLogs", $processstop)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome

}