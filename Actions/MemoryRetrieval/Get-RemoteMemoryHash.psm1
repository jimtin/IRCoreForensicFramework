function Get-RemoteMemoryHash {
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
        "HostHunterObject" = "Get-RemoteMemoryHash"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    $remotehashval = Invoke-HostHunterCommand -Target $Target -Scriptblock{
        # Set up the output variable
        $output = @{
            "Endpoint" = $env:COMPUTERNAME
            "DateTime" = (Get-Date).ToString()
        }

        # Get the SHA256 Hash
        $sha256hash = Get-FileHash -Path C:\PerformanceInformation\memory.raw -Algorithm SHA256
        $output.Add("SHA256Hash", $sha256hash)
    }

    # Add the outcome of all the hash values to the output
    $outcome.Add("HashValue", $remotehashval)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return to the user
    Write-Output $outcome

}