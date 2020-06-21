function Get-WindowsPrefetch {
    <#
    .SYNOPSIS
    Gets windows prefetch from staging location, brings it back to the processing machine

    .DESCRIPTION
    Gets windows prefetch from staging location, brings it back to the processing machine

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

    # Set up the destination directory
    $ExtractionPath = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts"
    
    # Copy the prefetch folder, recursively
    Copy-Item -FromSession $target -Path "C:\PerformanceInformation\Prefetch" -Destination $ExtractionPath -Recurse
    # Test they were copied successfully
    $prefetchpath = $ExtractionPath + "\Prefetch"
    $prefetchcopied = Test-Path -Path $prefetchpath
    $outcome.Add("PrefetchExtractionOutcome", $prefetchcopied)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return the outcome to the user
    Write-Output $outcome
}