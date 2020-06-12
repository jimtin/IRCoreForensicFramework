function Set-PythonAnalysisList {
    <#
    .SYNOPSIS
    Sets the PythonAnalysisFolder up

    .DESCRIPTION
    Sets the PythonAnalysisFolder up
    #>
    param (
        
    )

    # Get the location
    $Location = (Get-Location).ToString()

    # Test the path
    $folder = $Location + "\PythonAnalysisList"
    $path = Test-Path -Path $folder

    # If it's not there, create it
    if($path -ne $true){
        New-Item -Path $Location -Name PythonAnalysisList -ItemType Directory
    }

    $path = Test-Path -Path $folder

    Write-Output $path
    
}