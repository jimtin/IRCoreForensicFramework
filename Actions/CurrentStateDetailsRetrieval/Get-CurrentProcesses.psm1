function Get-CurrentProcesses {
    <#
    .SYNOPSIS
    Takes a snapshot of the currently running processes on the target endpoint. This can be used to answer the question "Was this process running when we took the snapshot?"
    
    .DESCRIPTION
    Takes a snapshot of the currently running processes on the target endpoint. This can be used to answer the question "Was this process running when we took the snapshot?"

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-CurrentProcesses"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Get the processes
    $processes = Invoke-HostHunterCommand -Target $Target -Scriptblock{Get-Process}

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add the results to outcome dictionary
    $outcome.Add("EndpointOutcomes", $pathexists)

    # Write directly to file
    $outfile = "C:\ExtractionDirectory\" + $Target.ComputerName +"_ForensicArtifacts\CurrentStateInformation\processes.json"
    $processes | ConvertTo-Json | Out-File $outfile
    
    # Return results to pwsh
    Write-Output $outcome
    
}