function Get-Executeable{
    <#
    .SYNOPSIS
        Gets executeable to enable generic IR Forensics to occur
    .DESCRIPTION
        Downloads core executeable as specified in the manifest
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$DownloadURL,
        [Parameter(Mandatory=$true)]$OutputLocation,
        [Parameter(Mandatory=$true)]$ExeName
    )

    # Setup the output dictionary
    $output = @{
        "Exename" = $ExeName
        "DownloadUrl" = $DownloadURL
    }

    # Get the current location
    $location = (Get-Location).ToString()
    # Create the output path
    $outputpath = $location + "\" + $OutputLocation + "\" + $ExeName
    
    # Notify the user
    $message = "Downloading " + $ExeName + " to " + $outputpath
    Write-Information -InformationAction Continue -MessageData $message

    # Invoke the Web Request to download
    $download = Invoke-WebRequest -Uri $DownloadURL -OutFile $outputpath

    # Add the outcome to output
    $output.Add("Outcome", $download)

    # Return outcome to user
    Write-Output $output
    
}