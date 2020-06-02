function Copy-Volatility {
    <#
    .SYNOPSIS
    Copies volatility from the download location across to the PythonAnalysisList location

    .DESCRIPTION
    Copies volatility3 from Executeables folder across to PythonAnalysisList folder, then unzips

    #>
    param (
        
    )

    # Create output dictionary
    $output = @{}

    # Check if volatility3 folder already exists
    $volatility = Test-Path -Path \PythonAnalysisList\volatility3
    $output.Add("VolatilityPresent", $volatility)

    # If it doesnt exist, copy then unzip
    if($volatility -ne $true){
        # Copy zipped file to PythonAnalysisList
        $copy = Copy-Item -Path "\Executeables\volatility3-master.zip" -Destination "\PythonAnalysisList\volatility-master.zip"
        $output.Add("VolatilityTransferred", $copy)

        # Unzip file
        $expandedvolatility = Expand-Archive -Path "\PythonAnalysisList\volatility3-master.zip" -DestinationPath "\PythonAnalysisPath\volatility3"
        $output.Add("VolatilityExpanded", $expandedvolatility)

        # Delete the zip fil
        $removezip = Remove-Item -Path "\PythonAnalysisList\volatility3-master.zip"
        $output.Add("VolatilityDeleted", $removezip)

    }else {
        Write-ColoredInformation -MessageData "Volatility exists"
    }

    # Return output to the user
    Write-Output $output
    
}