function Copy-RemoteEventLogging{
    <#
    .SYNOPSIS
    Copies the remote event logs into the performance information folder

    .DESCRIPTION
    Copies the remote event logs into the performance information folder
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )
    
    # Setup overall outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-RemoteEventLogging"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $copylog = Invoke-HostHunterCommand -Target $Target -ScriptBlock{
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
    $outcome.Add("Outcome", $copylog)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)
    
    # Return outcome from this command
    Write-Output $outcome
}