function Get-ExtractedMemoryHash {
    <#
    .SYNOPSIS
    Gets the SHA256 and MD5 hash of the remote memory dump

    .DESCRIPTION
    Gets the SHA256 and MD5 has of the remote memory dump. This hash is used to confirm the extracted memory dump matches the original
    
    #>
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up the output dictionary
    $outcome = @{
        "HostHunterObject" = "Get-ExtractedMemoryHash"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Construct the path where the hash will exist
    $path = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts\memory.raw"

    # Get the SHA256 Hash
    $sha256hash = Get-FileHash -Path $path -Algorithm SHA256
    $outcome.Add("SHA256Hash", $sha256hash)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return to the user
    Write-Output $outcome

}