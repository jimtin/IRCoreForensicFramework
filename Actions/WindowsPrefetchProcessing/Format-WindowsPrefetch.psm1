function Format-WindowsPrefetch {
    <#
    .SYNOPSIS
    Formats windows prefetch files into JSON, preparing for post processing

    .DESCRIPTION
    Formats windows prefetch files into JSON, preparing for post processing.
    Uses Eric Zimmermans excellent tool PECmd.exe https://ericzimmerman.github.io/#!index.md

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Format-WindowsPrefetch"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Set up the location variables
    $prefetchfolder = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\Prefetch"
    $outputfolder = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts"

    # Run the executeable with output json
    .\Executeables\PECmd.exe -d $prefetchfolder --json $outputfolder --jsonf "Prefetch.json" | Out-Null

    # Test that file successfully created
    $prefetchjson = $outputfolder + "\Prefetch.json"
    $prefetchjsonexists = Test-Path -Path $prefetchjson
    $outcome.Add("PrefetchOutcome", $prefetchjsonexists)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome
    
}