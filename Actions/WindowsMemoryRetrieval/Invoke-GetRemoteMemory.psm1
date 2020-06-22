function Invoke-GetRemoteMemory {
    <#
    .SYNOPSIS
    Combines all the HostHunter Commandlets together to go and get a remote memory dump. 

    .DESCRIPTION
    1. Pushes WinPmem executeable across to remote machine - Move-WinPMEM
    2. Invokes a memory dump - Invoke-MemoryDump
    3. Retrieves the remote memory dump - Get-MemoryDump
    4. Gets a SHA256 Hash of the initial memory dump - Get-RemoteMemoryHash
    5. Gets a SHA256 Hash of the extracted memory dump - Get-ExtractedMemoryHash
    6. Compares the memory hashes together - Compare-MemoryHashes

    #>
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Setup the outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-GetRemoteMemory"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Move WinPmem to remote target
    $winpmemmove = Move-WinPmem -Target $Target
    $outcome.Add("WinPMEMMove", $winpmemmove)

    # Invoke a memory dump
    $memdump = Invoke-MemoryDump -Target $Target
    $outcome.Add("Memdump", $memdump)

    # Get the memory dump
    $memdumpretrieval = Get-MemoryDump -Target $Target
    $outcome.Add("MemdumpRetrieval", $memdumpretrieval)

    # Get and compare memory hashes
    $hashcomparison = Compare-MemoryHashes -Target $Target
    $outcome.Add("MemoryHashComparison", $hashcomparison)

    # todo: if memory hashes don't match, go and get memory again

    # Confirm that the memory dump has been retrieved successfully
    $location = "C:\ExtractionDirectory\" + $target.ComputerName + "_ForensicArtifacts\memory.raw"
    $memoryretrieved = Test-Path -Path $location
    $outcome.Add("MemoryDumpRetrieved", $memoryretrieved)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return outcomes to user
    Write-Output $outcome
}