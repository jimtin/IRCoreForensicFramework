function Join-WindowsProcessArtefacts {
    <#
    .SYNOPSIS
    Processes the avaiable forensic artefacts for processes together to create a single unified process object.

    .DESCRIPTION
    Processes the avaiable forensic artefacts for processes together to create a single unified process object.
    Requires the Invoke-CoreForensicArtifactGathering and Processing Playbooks to have run. 

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
    $baselocation = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\"

    # Get the processes which were running at the time of acquisition
    $currentprocesses = $baselocation = "CurrentStateInformation\processes.json"
    $runningprocesses = Get-Content $currentprocesses | ConvertFrom-Json

    # For now, let's work with a single process to develop a search strategy
    # 1. Get a current process which I know about
    # 2. Let's work through all the artefacts I have - process start, process stop, prefetch, memory, SRUM. What is unique across all of them? 

    # Stop the stopwatch
    $stopwatch.Stop()

    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome

}