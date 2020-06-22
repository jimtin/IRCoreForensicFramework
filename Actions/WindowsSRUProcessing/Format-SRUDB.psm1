function Format-SRUDB {
    <#
    .SYNOPSIS
    Gets the SRUDB.dat file and runs the excellent srum-dump executeable by Mark Baggett

    .DESCRIPTION
    Uses the excellent work done by Mark Baggett here: https://github.com/MarkBaggett/srum-dump
    Transforms the information from SRUDB into an excel file
    
    #>
    param (
        [Parameter(Mandatory=$true)][string]$Target,
        [Parameter()][switch]$registryexists
    )

    # Create the outcome dictionary
    $outcome = @{
        "HostHunterObject" = "Format-SRUDB"
        "DateTime" = (Get-Date).ToString()
        "Target" = $target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Create input location
    $inputloc = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\EventLoggingandSRU\sru\SRUDB.dat"
        
    # Add to the output object
    $outcome.Add("InputLocation", $inputloc)

    # Create the output location
    $outputloc =  "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts\ProcessedArtefacts\sru_database.xlsx"
        
    # Add to the output object
    $outcome.Add("OutputLocation", $outputloc)

    # If registry exists, run file with registry option
    if($registryexists){
        $outcome.Add("RegistryExists", $true)

        # Set up the registry hive location
        $registryhive = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\Registry\HKLM.reg"
        $outcome.Add("RegistryHiveLocation", $registryhive)

        # Run the executeable
        $srumdb = .\Executeables\srum_dump2.exe --SRUM_INFILE $inputloc --XLSX_OUTFILE $outputloc --XLSX_TEMPLATE ".\Executeables\SRUM_TEMPLATE2.xlsx" --REG_HIVE $registryhive
        $outcome.Add("SRUMDBOutput", $srumdb)
    }else {
        $outcome.Add("RegistryExists", $false)

        # Set up the registry hive location
        $registryhive = "Doesnotexist"
        $outcome.Add("RegistryHiveLocation", $srumdb)

        # Run the executeable
        $srumdb = .\Executeables\srum_dump2.exe --SRUM_INFILE $inputloc --XLSX_OUTFILE $outputloc --XLSX_TEMPLATE ".\Executeables\SRUM_TEMPLATE2.xlsx"
        $outcome.Add("SRUMDBOutput", $srumdb)
    }

    # Test SRU Formatted file exists
    $sruoutput = Test-Path -Path $outputloc
    $outcome.Add("SRUFileOutcome", $sruoutput)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return outcomes to the user
    Write-Output $output
}