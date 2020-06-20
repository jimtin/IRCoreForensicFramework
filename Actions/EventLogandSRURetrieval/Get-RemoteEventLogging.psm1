function Get-RemoteEventLogging{
    <#
    .SYNOPSIS
    Gets the remote event logs from the endpoint. Renames it to the hostname of endpoint. 

    .DESCRIPTION
    Gets the remote event logs from the endpoint. Renames it to the hostname of the endpoint. 
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Setup the outcome variable
    $outcome = @{
        "HostHunterObject" = "Get-RemoteEventLogging"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Extract the logging artifacts from each endpoint in parallel

    # Set up the destination directory
    $LoggingPath = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts"

    # Test if directory already exists, if not, create it
    $ExtractionPath = $LoggingPath + "\EventLoggingandSRU" 
    $path = Test-Path -Path $testpath
    if($path -ne $true){
        New-Item -Path $LoggingPath -Name "EventLoggingandSRU" -ItemType "directory" | Out-Null
    }

    # Copy the Event Logs
    Copy-Item -FromSession $Target -Path "C:\PerformanceInformation\Logs" -Recurse -Destination $ExtractionPath | Out-Null
    # Test they were successfully extracted
    $logpath = $ExtractionPath + "\Logs"
    $eventlogsoutcome = Test-Path -Path $logpath
    $outcome.Add("EventLogExtractionOutcome", $eventlogsoutcome)

    # Copy the SRU
    $sru = Copy-Item -FromSession $Target -Path "C:\PerformanceInformation\sru" -Recurse -Destination $ExtractionPath
    # Test they were successfully extracted
    $srupath = $ExtractionPath + "\sru"
    $sruoutcome = Test-Path -Path $srupath
    $outcome.Add("SRUExtractionOutcome", $sruoutcome)
    
    # Return the outcome to the user
    Write-Output $outcome
}