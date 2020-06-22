function Invoke-VolatilityPSScan {
    <#
    .SYNOPSIS
    Runs the PsScan module from Volatility3

    .DESCRIPTION
    Using the modules from Volatility3, PsScan then formats output into a Powershell object
    References:
    1. Volatility3: https://github.com/volatilityfoundation/volatility3
    2. Modules: https://volatility3.readthedocs.io/en/latest/

    Target can be selected, but defaults to all targets
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )
    
    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-VolatilityPSList"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Construct the file location
    $memfilelocation = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\memory.raw"

    # Construct the output directory
    $outputdir = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\"

    # Run volatility command PSScan
    $results = python .\PythonAnalysisList\volatility3\vol.py --file $memfilelocation --output-dir $outputdir windows.psscan.PsScan
        
    # Turn into powershell objects
    $volatilityobjects = Format-VolatilityOutput -VolatilityFunctionOutput $results

    # Add to the output variable
    $output.Add("PSScanResults", $volatilityobjects)

    # Output to a file in case future forensic work is needed
    # Create the file string
    $outfilestring = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\ProcessedArtefacts\VolatilityPsScanResults.json"
        
    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)
    
    # Output to the folder
    $outcome | ConvertTo-Json | Out-File $outfilestring

    # Return output to user
    Write-Output $outcome
}