function Expand-PrefetchParser {
    <#
    .SYNOPSIS
    Extracts the prefetch parser from the zip download

    .DESCRIPTION
    Extracts Eric Zimmermans excellent prefetch tool from the zip file it downloaded to.
    Credits: https://ericzimmerman.github.io/#!index.md
    Please consider supporting Eric Zimmerman

    #>
    [CmdletBinding()]
    param (
        
    )

    # Set up the location of the prefetch parser
    $location = (Get-Location).ToString()
    $prefetchlocation = $location + "\Executeables\PECmd.zip"
    $prefetchunzipped = $location + "\Executeables\PECmd.exe"
    $exeloc = $location + "\Executeables"

    # Test if unzipped file exists
    $prefetchready = Test-Path -Path $prefetchunzipped

    # If it doesn't, expand the zip file
    if($prefetchready -ne $true){
        Write-HostHunterInformation -MessageData "Expanding prefetch parser"
        Expand-Archive -Path $prefetchlocation -DestinationPath $exeloc
    }

    Write-HostHunterInformation -MessageData "Prefetch Parser available" -ForegroundColor "Cyan"

}