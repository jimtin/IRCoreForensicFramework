function Invoke-WindowsMemoryImageProcessing {
    <#
    .SYNOPSIS
    Runs all the volatility commands added in on extracted memory image

    .DESCRIPTION
    Runs all the volatility commands added in on extracted memory image. So far:
    1. Cmdline
    2. PSList
    3. PSScan 
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-WindowsMemoryImageProcessing"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Get Windows Volatility Commandline
    $cmdline = Invoke-VolatilityCmdline -Target $Target
    $outcome.Add("VolatilityCmdlineOutcome", $cmdline)

    # Get Windows PSList
    $pslist = Invoke-VolatilityPSList -Target $Target
    $outcome.Add("VolatilityPSListOutcome", $pslist)

    # Get Windows PSScan
    $psscan = Invoke-VolatilityPSScan -Target $Target
    $outcome.Add("VolatilityPSScanOutcome", $psscan)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome
    
}