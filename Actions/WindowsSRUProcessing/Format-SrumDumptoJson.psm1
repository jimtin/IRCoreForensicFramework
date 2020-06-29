function Format-SrumDumptoJson {
    <#
    .SYNOPSIS
    Takes the output from srumdump2 and converts key sheets into Json

    .DESCRIPTION
    Takes the output from srumdump2 and converts key sheets into Json. Does this by first converting into csv, then doing conversion.
    Uses the ImportExcel module by dfinke https://github.com/dfinke/ImportExcel
     
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Format-SrumDumptoJson"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Set up the filepath
    $location = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts\sru_database.xlsx"
    $location2 = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts"

    # Extract the worksheets I want and turn them into CSVs. Then import and turn into json. This is done as trying to convert directly to JSON is extremely time consuming
    # SRUM Network Usage Sheet
    $networkusage = Import-Excel -Path $location -WorksheetName "Network Usage"
    $outfile = $location2 + "\srum_network_usage.json"
    $networkusage | ConvertTo-Json | Out-File $outfile
    $outcome.Add("SRUMNetworkUsageJSON", $true)

    # SRUM Application Resource Usage
    $applicationresourceusage = Import-Excel -Path $location -WorksheetName "Application Resource Usage"
    $outfile = $location2 + "\srum_application_resource_usage.json"
    $applicationresourceusage | ConvertTo-Json | Out-File $outfile
    $outcome.Add("SRUMApplicationResourceUsageJSON", $true)

    # SRUM Network Connections
    $networkconnections = Import-Excel -Path $location -WorksheetName "Network Connections"
    $outfile = $location2 + "\srum_network_connections.json" 
    $networkconnections | ConvertTo-Json | Out-File $outfile
    $outcome.Add("SRUMNetworkConnectionsJSON", $true)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome
    
}