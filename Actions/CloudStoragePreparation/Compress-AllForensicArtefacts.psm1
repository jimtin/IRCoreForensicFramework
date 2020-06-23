function Compress-AllForensicArtefacts {
    <#
    .SYNOPSIS
    Uses native windows tools to compress full forensic artifacts folder into a more manageable size

    .DESCRIPTION
    Uses native windows tools to compress full forensic artifacts folder into a more manageable size

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )
    
    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Compress-AllForensicArtefacts"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Set up the location and destination paths
    $location = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts"
    $destination = "C:\ExtractionDirectory\" + $Target + "_Compressed.zip"

    # Add in the compression .NET API
    Add-Type -Assembly System.IO.Compression.FileSystem

    # Set the compression level
    $compressionlevel = [System.IO.Compression.CompressionLevel]::Optimal

    # Now Zip it
    [System.IO.Compression.ZipFile]::CreateFromDirectory($location, $destination, $compressionlevel, $false)

    # Test that the zip file has been created
    $zipcreated = Test-Path -Path $destination
    $outcome.Add("Outcome", $zipcreated)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome

}