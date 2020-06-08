function Format-SRUDB {
    <#
    .SYNOPSIS
    Gets the SRUDB.dat file and runs the excellent srum-dump executeable by Mark Baggett

    .DESCRIPTION
    Uses the excellent work done by Mark Baggett here: https://github.com/MarkBaggett/srum-dump
    Transforms the information from SRUDB into an excel file
    
    #>
    param (
        [Parameter()]$Target = ""
    )

    # Create the output dictionary
    $output = @{
        "HostHunterObject" = "Format-SRUDB"
        "DateTime" = (Get-Date).ToString()
    }

    # Get the endpoint from the target list
    $endpoints = Get-TargetList

    if($Target -ne ""){
        $endpoints = $Target
    }

    foreach($endpoint in $endpoints){
        # Create dictionary for output
        $endpointdict = @{}

        # Create input location
        $inputloc = "C:\ExtractionDirectory\" + $endpoint + "_ForensicArtifacts\EventLoggingandSRU\sru\SRUDB.dat"
        
        # Add to the output object
        $endpointdict.Add("InputLocation", $inputloc)

        # Create the output location
        $outputloc =  "C:\ExtractionDirectory\" + $endpoint + "_ForensicArtifacts\EventLoggingandSRU\ProcessedOutcomes\sru_database.xlsx"
        
        # Add to the output object
        $endpointdict.Add("OutputLocation", $outputloc)

        # Now run the executeable
        $srumdb = .\Executeables\srum_dump2.exe --SRUM_INFILE $inputloc --XLSX_OUTFILE $outputloc --XLSX_TEMPLATE ".\Executeables\SRUM_TEMPLATE2.xlsx"
        
        # Add the results to the output object
        $endpointdict.Add("SRUDB_Processing", $srumdb)

        # Add all results to the output dictionary
        $output.Add($endpoint, $endpointdict)
    }

    # Return outcomes to the user
    Write-Output $output
}