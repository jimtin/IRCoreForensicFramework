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
        $copy = Copy-Item -Path "\Executeables\volatility3.zip" -Destination "\PythonAnalysisList\volatility3.zip"
        $output.Add("VolatilityTransferred", $copy)

        # Unzip file
        $expandedvolatility = Expand-Archive -Path "\PythonAnalysisList\volatility3.zip" -DestinationPath "\PythonAnalysisPath\volatility3-master"
        $output.Add("VolatilityExpanded", $expandedvolatility)

        # Now remove the extra file gained from the unzip process
        $copy = Copy-Item -Path "\PythonAnalysisList\volatility3-master\volatility3-master" -DestinationPath "\PythonAnalysisPath\volatility3"

        # Delete the original unzip
        Remove-Item -Path "\PythonAnalysisList\volatility3-master" -Recurse

        # Delete the git and development folders in volatility
        Remove-Item -Path "\PythonAnalysisList\volatility3\.github" -Recurse
        Remove-Item -Path "\PythonAnalysisList\volatility3\development" -Recurse

        # Delete the zip file
        $removezip = Remove-Item -Path "\PythonAnalysisList\volatility3.zip"
        $output.Add("VolatilityDeleted", $removezip)

    }else {
        Write-HostHunterInformation -MessageData "Volatility exists"
    }

    # Return output to the user
    Write-Output $output
    
}