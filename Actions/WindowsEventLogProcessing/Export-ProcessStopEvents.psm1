function Export-ProcessStopEvents {
    <#
    .SYNOPSIS
    Exports process stop events from the Security event logs

    .DESCRIPTION
    Exports process stop events from the Security event logs. Assumes that event log file exists, but checks for process start events.

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )

    # Create outcome variable
    $outcome = @{
        "HostHunterObject" = "Export-ProcessStopEvents"
        "DateTimeCreated" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Construct the path
    $logpath = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\EventLoggingandSRU\Logs\Security.evtx"

    # First extract the process start logs from security log
    $processstoplogs = Get-WinEvent -FilterHashtable @{
        Id = "4689"
        Path = $logpath
    }

    # Create the output dictionary
    $formattedlogs = @()

    # Iterate through the logs, create the output needed
    foreach($procstop in $processstoplogs){
        # Create the object to store everything in
        $processobject = @{
            "Source" = "ExtractedEventLogs"
            "Type" = "ProcessStop"
            "Target" = $Target
            "ProcessId" = $procstop.Properties[5].Value
            "DateTime" = $procstop.TimeCreated
            "SecurityID" = $procstop.Properties[0].Value.Value
            "AccountName" = $procstop.Properties[1].Value
            "AccountDomain" = $procstop.Properties[2].Value
            "LogonID" = $procstop.Properties[3].Value.Value
            "ProcessStartPath" = $procstop.Properties[6].Value
            "ProcessExitStatus" = $procstop.Properties[4].Value
            "EventLogRecordId" = $procstop.RecordId
        }

        # Add the log object back to formattedlogs array
        $formattedlogs += $processobject
    }

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add back to outcome 
    $outcome.Add("ProcessStopLogs", $formattedlogs)

    # Output formatted logs to processed artifacts
    $processedartifactspath = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts\processstops.json"
    $outcome | ConvertTo-Json | Out-File $processedartifactspath
    
    # Return back to user
    Write-Output $outcome
}