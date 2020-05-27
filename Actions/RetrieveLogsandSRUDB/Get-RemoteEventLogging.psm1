function Get-RemoteEventLogging{
    <#
    .SYNOPSIS
    Gets the remote event logs from the endpoint. Renames it to the hostname of endpoint. 

    .DESCRIPTION
    Gets the remote event logs from the endpoint. Renames it to the hostname of the endpoint. 
    
    #>
    [CmdletBinding()]
    param (
        
    )

    # Setup the outcome variable
    $outcome = @{}

    # Get a list of the sessions
    $sessions = Get-TargetSessions

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