function Compare-MemoryHashes {
    <#
    .SYNOPSIS
    Function which compares hashes together from before and after extraction over network

    .DESCRIPTION
    Takes hashes from before and after network extraction and compares them together

    #>
    param (
        [Parameter(Mandatory=$true)]$RemoteMemoryHash,
        [Parameter(Mandatory=$true)]$LocalMemoryHash,
        [Parameter(Mandatory=$true)]$Target
    )

    # Set up outcome
    $outcome = $false

    # Compare SHA256 Hashes
    if($RemoteMemoryHash.HashValues[$Target].SHA256Hash.Hash -eq  $LocalMemoryHash.HashValues[$Target].SHA256Hash.Hash){
        $message = "Memory Hash comparison for " + $Target + ": Matched"
        # Write-HostHunterInformation -MessageData $message
        $outcome = $true
    }else{
        $message = "Memory Hash comparison for " + $Target + ": Failed"
        # Write-HostHunterInformation -MessageData $message -ForegroundColor "Red"
    }

    # Return outcome to the user
    Write-Output $outcome
    
}