function Format-SRUDBtoJSON {
    <#
    .SYNOPSIS
    Converts an extracted SRU Database into a series of JSON files

    .DESCRIPTION
    Converts an extracted SRU Database into a series of JSON files. Does this using two commandlets

    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target,
        [Parameter()][switch]$registryexists
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Format-SRUDBtoJSON"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Convert SRU to XLSX using Mark Baggerts SRUMDUMP2
    if($registryexists){
        $srumdump = Format-SRUDBtoXLSX -Target $Target -registryexists
    }else {
        $srumdump = Format-SRUDBtoXLSX -Target $Target
    }
    
    $outcome.Add("SRUMDumpOutcome", $srumdump)

    #Convert SRUM Dump to JSON 
    $srumtojson = Format-SrumDumptoJson -Target $Target
    $outcome.Add("SRUMtoJSON", $srumtojson)

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return back to user
    Write-Output $outcome
    
}