function Get-MemoryDump{
    <#
    .SYNOPSIS
    Gets the memory dump from the target endpoints using a Powershell Session

    .DESCRIPTION
    Retrieves the memory dump using a Powershell Session
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]$Target
    )

    # Set up the outcome dictionary
    $outcome = @{
        "HostHunterObject" = "Get-MemoryDump"
        "DateTime" = (Get-Date).ToString()
    }

    # Get a list of the sessions
    $sessions = Get-TargetSessions

    # If there is a target, reduce the sessions to that target
    if($Target -ne ""){
        $sessions = $sessions | Where-Object {$_.ComputerName -eq $Target}
    }

    # Set up the extraction directory
    $path = Test-Path C:\ExtractionDirectory
    if ($path -ne $true){
        $directory = New-Item -Path "C:\" -Name "ExtractionDirectory" -ItemType "directory"
    }

    # Extract memory from each object in parallel. Have set extraction directory as static as this will enable further movement.
    ForEach-Object -InputObject $sessions -Parallel{
        # Get the session from the Input Object
        $sesh = $_
        
        # Get the name of the endpoint
        $TargetName = $_.ComputerName

        # Set up the destination directory
        $DirectoryName = $TargetName + "_ForensicArtifacts"
        $directory = New-Item -Path "C:\ExtractionDirectory" -Name $DirectoryName -ItemType "directory"

        # Get Destination Directory path
        $ExtractionPath = "C:\ExtractionDirectory\" + $DirectoryName

        # Actually copy the item finally
        Copy-Item -FromSession $sesh -Path C:\PerformanceInformation\memory.raw -Destination $ExtractionPath

    } 

    # Return object to the user
    Write-Output $outcome    
}