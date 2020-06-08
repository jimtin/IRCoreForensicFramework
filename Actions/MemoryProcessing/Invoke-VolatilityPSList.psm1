function Invoke-VolatilityPSList {
    <#
    .SYNOPSIS
    Runs the PSList module from Volatility3

    .DESCRIPTION
    Using the modules from Volatility3, PsLIst then formats output into a Powershell object
    References:
    1. Volatility3: https://github.com/volatilityfoundation/volatility3
    2. Modules: https://volatility3.readthedocs.io/en/latest/

    Target can be selected, but defaults to all targets
    #>
    param (
        [Parameter()]$Targets = ""
    )
    
    # Create output variable
    $output=@{
        "HostHunterObject" = "Invoke-VolatilityPSList"
        "DateTime" = (Get-Date).ToString()
    }

    # If Target not specified, do this operation on all targets
    if($Targets -eq ""){
        # Get the target list
        $targets = Get-TargetList
    }

    # For each target in $targets, run modules sequentially
    foreach($target in $targets){
        $targetobject = @{
            "Endpoint" = $target
        }
        # Construct the file location
        $memfilelocation = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\memory.raw"

        # Construct the output directory
        $outputdir = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\"

        # Run volatility command PSScan
        $results = python .\PythonAnalysisList\volatility3\vol.py --file $memfilelocation --output-dir $outputdir windows.pslist.PsList
        
        # Turn into powershell objects
        $volatilityobjects = Format-VolatilityOutput -VolatilityFunctionOutput $results

        # Add to Target Object
        $targetobject.Add("PSListResults", $volatilityobjects)

        # Add to the output variable
        $output.Add($target, $targetobject)

        # Output to a file in case future forensic work is needed
        # Create the file string
        $outfilestring = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\PsListResults.json"
        
        # Output to the folder
        $output | ConvertTo-Json | Out-File $outfilestring

        # Output to a file in case future forensic work is needed
        # Create the file string
        $outfilestring = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\PsListResults.json"
        
        # Output to the folder
        $output | ConvertTo-Json -Depth 100 | Out-File $outfilestring
    }

    # Return output to user
    Write-Output $output
}