function Invoke-VolatilityProcessList {
    <#
    .SYNOPSIS
    Runs the PsList, PsScan and PsTree modules from Volatility3

    .DESCRIPTION
    Using the modules from Volatility3, runs PsList, PsScan and PsTree.
    References:
    1. Volatility3: https://github.com/volatilityfoundation/volatility3
    3. Modules: https://volatility3.readthedocs.io/en/latest/
    #>
    param (
        
    )
    
    # Create output variable
    $output=@{
        "Object" = "Invoke-VolatilityProcessList"
    }

    # Get the target list
    $targets = Get-TargetList

    # For each target in $targets, run modules sequentially
    foreach($target in $targets){
        # Construct the file location
        $memfilelocation = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\memory.raw"

        # Construct the output directory
        $outputdir = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\"

        # Run volatility command PSScan
        $results = python .\PythonAnalysisList\volatility3\vol.py --file $memfilelocation --output-dir $outputdir windows.psscan.PsScan
        
        # Filter the results so that only good things are returned. Also, if you're reading this, smile
        $results = $results[2..$results.Count]

        # Add to output variable
        $output.Add("PSScanResults", $results)
    }

    # Return output to user
    Write-Output $output
}