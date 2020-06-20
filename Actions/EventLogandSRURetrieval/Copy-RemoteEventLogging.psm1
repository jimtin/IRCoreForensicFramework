function Copy-RemoteEventLogging{
    <#
    .SYNOPSIS
    Copies the remote event logs into the performance information folder

    .DESCRIPTION
    Copies the remote event logs into the performance information folder
    
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )
    
    # Setup overall outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-RemoteEventLogging"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    $copylog = Invoke-HostHunterCommand -Target $Target -ScriptBlock{
        # Set up the outcome dictionary
        $outcome = @{}
        
        # Copy item
        $copyitem = Copy-Item -LiteralPath C:\Windows\System32\winevt\Logs -Destination C:\PerformanceInformation -Recurse
        $outcome.Add("EventLogCopy", $copyitem)
        $copysru = Copy-Item -LiteralPath C:\Windows\System32\sru -Destination C:\PerformanceInformation -Recurse
        $outcome.Add("SRULogCopy", $copysru)
        # Return results
        Write-Output $outcome
    }
    # Add the output from this command to the outcome variable
    $outcome.Add("Outcome", $copylog)
    
    # Return outcome from this command
    Write-Output $outcome
}