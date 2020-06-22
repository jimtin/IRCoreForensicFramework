function Format-SrumDumptoJson {
    <#
    .SYNOPSIS
    Takes the output from srumdump2 and converts key sheets into Json

    .DESCRIPTION
    Takes the output from srumdump2 and converts key sheets into Json. Does this by first converting into csv, then doing conversion.
     
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
    
    # Set up the COM object for excel sheet
    $xlsxObject = New-Object -ComObject Excel.Application

    # Set there to be no alerts
    $xlsxObject.DisplayAlerts = $false

    # Open the XLSX file 
    $srumdump2output = $xlsxObject.Workbooks.Open($location)

    # Extract the worksheets I want and turn them into CSVs. Then import and turn into json. This is done as trying to convert directly to JSON is extremely time consuming
    # SRUM Network Usage Sheet
    $csvpath = $location2 + "\srum_network_usage.csv"
    $jsonpath = $location2 + "\srum_network_usage.json"
    $networkusage = $srumdump2output.Worksheets | Where-Object {$_.Name -eq "Network Usage"}
    $networkusage.SaveAs($location2 + "\srum_network_usage.csv", 6)
    Import-Csv -Path $csvpath | ConvertTo-Json | Out-File $jsonpath
    $outcome.Add("SRUMNetworkUsageCSV", $true)
    $outcome.Add("SRUMNetworkUsageJSON", $true)

    # SRUM Application Resource Usage
    $csvpath = $location2 + "\srum_application_resource_usage.csv"
    $jsonpath = $location2 + "\srum_application_resource_usage.json"
    $applicationresourceusage = $srumdump2output.Worksheets | Where-Object {$_.Name -eq "Application Resource Usage"}
    $applicationresourceusage.SaveAs($location2 + "\srum_application_resource_usage.csv", 6)
    Import-Csv -Path $csvpath | ConvertTo-Json | Out-File $jsonpath
    $outcome.Add("SRUMApplicationResourceUsageCSV", $true)
    $outcome.Add("SRUMApplicationResourceUsageJSON", $true)

    # SRUM Network Connections
    $csvpath = $location2 + "\srum_network_connections.csv"
    $jsonpath = $location2 + "\srum_network_connections.json"
    $networkconnections = $srumdump2output.Worksheets | Where-Object {$_.Name -eq "Network Connections"}
    $networkconnections.SaveAs($location2 + "\srum_network_connections.csv", 6)
    Import-Csv -Path $csvpath | ConvertTo-Json | Out-File $jsonpath
    $outcome.Add("SRUMNetworkConnectionsCSV", $true)
    $outcome.Add("SRUMNetworkConnectionsJSON", $true)

    # Quit the excel process
    $xlsxObject.Quit()

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome
    
}