function Get-RemoteEventLogging{
    <#
    .SYNOPSIS
    Gets the remote event logs from the endpoint. Renames it to the hostname of endpoint. 

    .DESCRIPTION
    Gets the remote event logs from the endpoint. Renames it to the hostname of the endpoint. 
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]$Target = ""
    )

    # Setup the outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-RemoteEventLogging"
        "DateTime" = (Get-Date).ToString()
    }

    # Get a list of the sessions
    $sessions = Get-TargetSessions

    # If there's a target, get the target
    if($Target -ne ""){
        $sessions = $sessions | Where-Object {$_.ComputerName -eq $Target}
    }

    # Extract the logging artifacts from each endpoint in parallel
    ForEach-Object -InputObject $sessions -Parallel{
        # Get the session from the Input Object
        $sesh = $_

        # Get the name of the endpoint
        $TargetName = $_.ComputerName

        # Set up the destination directory
        $DirectoryName = $TargetName + "_ForensicArtifacts"
        $LoggingPath = "C:\ExtractionDirectory" + "\" + $DirectoryName
        $directory = New-Item -Path $LoggingPath -Name "EventLoggingandSRU" -ItemType "directory"

        # Get destination directory path
        $ExtractionPath = $LoggingPath + "\" + "EventLoggingandSRU"

        # In exciting news we can now copy items in parallel. Start with the EventLogs
        Copy-Item -FromSession $sesh -Path "C:\PerformanceInformation\Logs" -Recurse -Destination $ExtractionPath

        # Now copy the SRU
        Copy-Item -FromSession $sesh -Path "C:\PerformanceInformation\sru" -Recurse -Destination $ExtractionPath

    }

    Write-Output $outcome
}