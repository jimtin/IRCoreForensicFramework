function Move-WinPmem{
    <#
        .SYNOPSIS
        Moves WinPmem 1.6 across to target machine
        .DESCRIPTION
        Uses WinRM protocol to move Winpmem across to the local machine. 
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )
    # Set up outcome dictionary
    $outcome = @{
        "HostHunterObject" = "Move-WinPmem"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Copy WinPMEM using powershell session
    $winpmem = Copy-Item -Path .\Executeables\WinPmem.exe -Destination "C:\PerformanceInformation\mem_info.exe" -ToSession $Target

    # Stop the stopwatch
    $stopwatch.Stop()

    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add result to outcome variable
    $outcome.Add("WinPMEMTransferOutcome", $winpmem)
    
    # Return the outcome
    Write-Output $outcome
    
}