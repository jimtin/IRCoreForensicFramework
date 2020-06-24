function Export-ProcessStartEvents {
    <#
    .SYNOPSIS
    Exports process start events from the Security event logs

    .DESCRIPTION
    Exports process start events from the Security event logs. Assumes that event log file exists, but checks for process start events.

    #>
    [CmdletBinding()]
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

    # Construct the path
    $logpath = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\EventLoggingandSRU\Logs\Security.evtx"

    # First extract the process start logs from security log
    $processstartlogs = Get-WinEvent -FilterHashtable @{
        Id = "4688"
        Path = $logpath
    }

    # Create the output dictionary
    $formattedlogs = @()

    # Iterate through the logs, create the output needed
    foreach($procstart in $processstartlogs){
        # Create the object to store everything in
        $processobject = @{
            "Source" = "ExtractedEventLogs"
            "Type" = "ProcessStart"
            "Target" = $Target
            "DateTime" = $procstart.TimeCreated
            "SecurityID" = $procstart.Properties[0].Value.Value
            "CreatorAccountName" = $procstart.Properties[1].Value
            "CreatorAccountDomain" = $procstart.Properties[2].Value
            "CreatorLogonID" = $procstart.Properties[3].Value.Value
            "ProcessId" = $procstart.Properties[4].Value
            "ProcessStartPath" = $procstart.Properties[5].Value
            "TokenElevationType" = $procstart.Properties[6].Value
            "ParentProcessId" = $procstart.Properties[7].Value
            "ProcessCommandLine" = $procstart.Properties[8].Value
            "TargetSecurityId" = $procstart.Properties[9].Value.Value
            "TargetAccountName" = $procstart.Properties[10].Value
            "TargetAccountDomain" = $procstart.Properties[11].Value
            "TargetLogonId" = $procstart.Properties[12].Value
            "ParentProcessPath" = $procstart.Properties[13].Value
            "CreatorSecurityID" = $procstart.Properties[14].Value.Value
            "EventLogRecordId" = $procstart.RecordId
        }

        # Add the log object back to formattedlogs array
        $formattedlogs += $processobject
    }

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add back to outcome 
    $outcome.Add("ProcessStartLogs", $formattedlogs)

    # Output formatted logs to processed artifacts
    $processedartifactspath = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts\processstarts.json"
    $outcome | ConvertTo-Json | Out-File $processedartifactspath
    
    # Return back to user
    Write-Output $outcome
}