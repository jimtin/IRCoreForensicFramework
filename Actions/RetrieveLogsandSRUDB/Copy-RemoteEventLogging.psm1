function Copy-RemoteEventLogging{
    <#
    .SYNOPSIS
    Copies the remote event logs into the performance information folder

    .DESCRIPTION
    Copies the remote event logs into the performance information folder
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]$Target = ""
    )
    
    # Setup overall outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-RemoteEventLogging"
        "DateTime" = (Get-Date).ToString()
    }
    
    # Get the timestamp of the command being run
    $outcome.Add("CopyRemoteEventLogsTimestamp", (Get-Date).ToString())
    $copylog = Invoke-HostCommand -Targets $Target -ScriptBlock{
        # Set up the outcome dictionary
        $outcome = @{}
        
        # Copy item
        $copyitem = Copy-Item -LiteralPath C:\Windows\System32\winevt\Logs -Destination C:\PerformanceInformation -Recurse
        $outcome.Add("EventLogCopy", $copyitem)
        $copysru = Copy-Item -LiteralPath C:\Windows\System32\sru -Destination C:\PerformanceInformation -Recurse
        $outcome.Add("SRULogCopy", $copysru)
        # Return results
        Write-Output $outcome
    }
    # Add the output from this command to the outcome variable
    $outcome.Add("CopyRemoteEventLogsOutput", $copylog)
    # Return outcome from this command
    Write-Output $outcome
}