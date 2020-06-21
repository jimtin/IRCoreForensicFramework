function Invoke-GetWindowsPrefetch {
    <#
    .SYNOPSIS
    Gets window prefetch from a remote machine

    .DESCRIPTION
    Gets window prefetch from a remote machine

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Setup overall outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-WindowsPrefetch"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Copy window prefetch
    $prefetchcopy = Copy-WindowsPrefetch -Target $Target
    $outcome.Add("PrefetchCopyOutcome", $prefetchcopy)

    # Retrieve Prefetch folder from endpoint
    $prefetchretrieve = Get-WindowsPrefetch -Target $Target
    $outcome.Add("PrefetchGetOutcome", $prefetchretrieve)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return the outcome to the user
    Write-Output $outcome
    
}