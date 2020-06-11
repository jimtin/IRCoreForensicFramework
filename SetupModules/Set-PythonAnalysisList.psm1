function Set-PythonAnalysisFolder {
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
    $folder = $Location + "\PythonAnalysisFolder"
    $path = Test-Path -Path $folder

    # If it's not there, create it
    if($path -ne $true){
        New-Item -Path $Location -Name PythonAnalysisFolder -ItemType Directory
    }
    
}