function Compare-MemoryHashes {
    <#
    .SYNOPSIS
    Function which compares hashes together from before and after extraction over network

    .DESCRIPTION
    Takes hashes from before and after network extraction and compares them together

    #>
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome
    $outcome = @{
        "HostHunterObject" = "Compare-MemoryHashes"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Get the remote memory hash
    $RemoteMemoryHash = Get-RemoteMemoryHash -Target $Target
    $outcome.Add("RemoteHash", $RemoteMemoryHash)

    # Get the local memory hash
    $LocalMemoryHash = Get-ExtractedMemoryHash -Target $Target
    $outcome.Add("LocalHash", $LocalMemoryHash)

    # Compare SHA256 Hashes
    if($RemoteMemoryHash.SHA256Hash.Hash -eq  $LocalMemoryHash.SHA256Hash.Hash){
        $outcome.Add("HashComparison", $true) 
    }else{
        $outcome.Add("HashComparison", $false) 
    }

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return outcome to the user
    Write-Output $outcome
    
}