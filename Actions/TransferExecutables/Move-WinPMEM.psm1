function Move-WinPmem{
    <#
        .SYNOPSIS
        Moves WinPmem 1.6 across to target machine
        .DESCRIPTION
        Uses WinRM protocol to move Winpmem across to the local machine. 
    #>
    
    [CmdletBinding()]
    param (
        [Parameter()]$target = ""
    )
    # Set up outcome dictionary
    $outcome = @{
        "HostHunterObject" = "Move-WinPmem"
        "DateTime" = (Get-Date).ToString()
    }

    # Get a list of the sessions
    $sessions = Get-TargetSessions

    # If targets not empty, select the session for the target provided
    if($target -ne ""){
        $sessions = $sessions | Where-Object {$_.ComputerName -eq $target}
    }
    
    # Record action for each endpoint
    foreach($session in $sessions){
        $timestamp = (Get-Date).ToString()
        # Copy WinPMEM using powershell session
        $winpmem = Copy-Item -Path .\Executeables\WinPmem.exe -Destination "C:\PerformanceInformation\mem_info.exe" -ToSession $session
        # Record outcomes
        $eachhost = @{
            "TransferredWinPMEMTimestamp" = $timestamp
            "WinPMEMTransferOutcome" = "Transferred"
        }
        # Add result to outcome variable
        $outcome.Add($session.ComputerName, $eachhost)
    }
    
    # Return the outcome
    Write-Output $outcome
    
}