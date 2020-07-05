function Copy-ToDockerVolume {
    <#
    .SYNOPSIS
    Copies data from the Extraction Directory to the Docker Volume 'forensicdata'

    .DESCRIPTION
    Copies data from the Extraction Directory to the Docker Volume 'forensicdata'. This allows the data to persist once container is destroyed
    #>
    [CmdletBinding()]
    param (
        
    )

    # Create outcome object
    $outcome = @{
        "HostHunterObject" = "Copy-ToDockerVolume"
    }

    # Copy item across to the volume
    Copy-Item -Path "C:\ExtractionDirectory\" -Destination "C:\forensicdata" -Recurse | Out-Null
    
}