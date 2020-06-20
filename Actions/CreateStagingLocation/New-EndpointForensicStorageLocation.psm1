function New-EndpointForensicStorageLocation {
    <#
    .SYNOPSIS
    Creates a folder to store the forensic information extracted from an endpoint

    .DESCRIPTION
    Creates a folder to store the forensic information extracted from an endpoint

    #>
    [CmdletBinding()]
    param (
        [Parameter()][string]$Target, 
        [Parameter()][System.Management.Automation.Runspaces]$session
    )

    # Create output variable
    $output = @{
        "HostHunterObject" = "New-EndpointStorageLocation"
        "DateTime" = (Get-Date).ToString()
    }

    # Test path to see if it already exists
    $Location = "C:\ExtractionDirectory\" + $Target + "_ForensicArtifacts"
    $Location = Test-Path -Path $Location

    # If it doesn't, create it
    if($Location -ne $true){
        $foldername = $Target + "_ForensicArtifacts"
        $createfolder = New-Item -Path "C:\ExtractionDirectory" -Name $foldername -ItemType Directory
    }

    # Add to the output
    $output.Add("CreatedForensicArtifactStorage", $createfolder)

    # Return output to user
    Write-Output $output
    
}