function New-RegistryFileFolder{
    <#
    .SYNOPSIS
    Creates a new folder in Extracted Artifacts to store extracted registry files

    .DESCRIPTION
    Creates a new folder in Extracted Artifacts to store extracted registry files
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string]$Target
    )

    # Create output variable
    $output = @{
        "HostHunterObject" = "New-RegistryFileFolder"
        "DateTime" = (Get-Date).ToString()
    }

    # Set up the path to be used for the extraction directory
    $location = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts"

    # Test to see if folder already exists
    $path = Test-Path -Path C:\ExtractionDirectory\Registry

    # If path does not exist, create
    if($path -ne $true){
        New-Item -Path $location -Name "Registry" -ItemType Directory | Out-Null
    }

    # Store output
    $output.Add("FolderCreated", $true)

    # Return output to user
    Write-Output $output
}