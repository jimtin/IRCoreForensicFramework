function Join-WindowsProcessStartProcessStopLogs {
    <#
    .SYNOPSIS
    Joins together the process start and process stop logs from event logs

    .DESCRIPTION
    Joins together the process start and process stop logs from event logs

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )
    
    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Join-WindowsProcessArtefacts"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Set up the base location
    $baselocation = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts"

    # Get the process start logs
    $location = $baselocation + "\processstarts.json"
    $processstartlogs = Get-Content -Path $location | ConvertFrom-Json
    $processstartlogs = $processstartlogs.ProcessStartLogs

    # Get the process stop logs
    $location = $baselocation + "\processstops.json"
    $processstoplogs = Get-Content -Path $location | ConvertFrom-Json
    $processstoplogs = $processstoplogs.ProcessStopLogs

    $results = @()

    # For each process start, find the corresponding process stop if it exists
    foreach($processstart in $processstartlogs){
        # Get the Process Id
        $processid = $processstart.ProcessID
        $processstartpath = $processstart.ProcessStartPath
        $exename = $processstartpath.Split("\")[-1]

        # Get the process start date
        $processstartdate = $processstart.DateTime

        # Confirm if that value exists in the Process Stop logs
        $procstopexists = $processstoplogs.ProcessId -contains $processid

        # Set up the processstop results intermediate storage
        $intermediateresults = @()

        # If it does, iterate through the list and store any of those Process Ids
        if($procstopexists -eq $true){
            # Iterate through all the process stop events to add them to an initial holding array
            foreach($processstop in $processstoplogs){
                # Get the time the process stopped
                $processstopdate = $processstop.DateTime
                if($processstopdate -gt $processstartdate){
                    # Find the process Id
                    if($processstop.ProcessId -eq $processid){
                        # Confirm the process start path matches
                        if($processstop.ProcessStartPath -eq $processstartpath){
                            # Store the intermediate results so they can be de-duped
                            
                            $intermediateresults += $processstop
                        }
                    }
                }
                
            }
        }else {
            $processobject = @{
                "ProcessId" = $processid
                "ProcessStartPath" = $processstartpath
                "ProcessStopFound" = $false
            }
        }

        # Sort the intermediate results by DateTime, select the one closest to the start time of the process start
        $firstprocessstop = $intermediateresults | Sort-Object -Property DateTime | Select-Object -First 1
        
        # Create the process object to output
        $processobject = @{
            "ProcessId" = $processid
            "StartPath" = $processstartpath
            "ProcessStartTime" = $processstart.DateTime
            "ProcessStopTime" = $firstprocessstop.DateTime
            "ProcessCommandLine" = $processstart.ProcessCommandLine
            "ParentProcessID" = $processstart.ParentProcessID
            "SecurityID" = $processstart.SecurityID
            "CreatorSecurityID" = $processstart.CreatorSecurityID
            "EventLogProcessStartRecordId" = $processstart.EventLogRecordId
            "EventLogProcessStopRecordId" = $firstprocessstop.EventLogRecordId
            "ProcessStartEventLog" = $true
            "ProcessStopEventLog" = $true
            "FullProcessStartObject" = $processstart
            "FullProcessStopObject" = $firstprocessstop
            "ExecutableName" = $exename
        }

         # Add to the results array
         $results += $processobject
    }

    # Add the results to the outcome
    $outcome.Add("ProcessObjects", $results)

    # Stop the stopwatch
    $stopwatch.Stop()

    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome

}