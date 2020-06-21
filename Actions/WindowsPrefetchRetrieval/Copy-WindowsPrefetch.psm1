function Copy-WindowsPrefetch{
    <#
    .SYNOPSIS
    Copies Windows Prefetch into the performance information folder

    .DESCRIPTION
    Copies Windows Prefetch into the performance information folder
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )
    
    # Setup overall outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-WindowsPrefetch"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $copylog = Invoke-HostHunterCommand -Target $Target -ScriptBlock{
        # Set up the outcome dictionary
        $outcome = @{}
        
        # Copy item
        $copyitem = Copy-Item -LiteralPath C:\Windows\Prefetch -Destination C:\PerformanceInformation -Recurse
        $outcome.Add("EventLogCopy", $copyitem)
        
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