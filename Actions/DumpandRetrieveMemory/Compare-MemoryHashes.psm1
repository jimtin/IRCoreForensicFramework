function Compare-MemoryHashes {
    param (
        [Parameter(Mandatory=$true)]$RemoteMemoryHash,
        [Parameter(Mandatory=$true)]$LocalMemoryHash
    )

    # Set up outcome
    $outcome = $false

    # Compare SHA256 Hashes
    if($RemoteMemoryHash.HashValues.SHA256Hash.Hash -eq )
    
}