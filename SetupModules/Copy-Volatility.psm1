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

    # Set up the path correctly
    $location = (Get-Location).ToString()

    # Check if volatility3 folder already exists
    $volatilitylocation = $location + "\PythonAnalysisList\volatility3"
    $volatility = Test-Path -Path $volatilitylocation
    $output.Add("VolatilityPresent", $volatility)

    # If it doesnt exist, copy then unzip
    if($volatility -ne $true){
        $volzip = $location + "\Executeables\volatility3.zip"
        $destvolzip = $volatilitylocation + ".zip"
        # Copy zipped file to PythonAnalysisList
        $copy = Copy-Item -Path $volzip  -Destination $destvolzip
        $output.Add("VolatilityTransferred", $copy)

        # Unzip file
        $volmaster = $location + "\PythonAnalysisList"
        $expandedvolatility = Expand-Archive -Path $destvolzip -DestinationPath $volmaster
        $output.Add("VolatilityExpanded", $expandedvolatility)

        # Delete the original unzip
        Remove-Item -Path $destvolzip

        # Rename extracted folder
        $volmaster = $location + "\PythonAnalysisList\volatility3-master"
        Rename-Item -Path $volmaster -NewName volatility3

        # Delete the git and development folders in volatility
        $githubpath = $volatilitylocation + "\.github"
        Remove-Item -Path $githubpath -Recurse
        $devpath = $volatilitylocation + "\development"
        Remove-Item -Path $devpath -Recurse

    }else {
        Write-HostHunterInformation -MessageData "Volatility exists"
    }

    # Return output to the user
    Write-Output $output
    
}