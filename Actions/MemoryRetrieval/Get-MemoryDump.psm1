function Get-MemoryDump{
    <#
    .SYNOPSIS
    Gets the memory dump from the target endpoints using a Powershell Session

    .DESCRIPTION
    Retrieves the memory dump using a Powershell Session
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up the outcome dictionary
    $outcome = @{
        "HostHunterObject" = "Get-MemoryDump"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Setup the extraction path
    $ExtractionPath = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts"

    # Copy the memory dump file from the remote endpoint
    $memdump = Copy-Item -FromSession $Target -Path C:\PerformanceInformation\memory.raw -Destination $ExtractionPath
    $outcome.Add("MemDumpOutcome", $memdump)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return object to the user
    Write-Output $outcome    
}