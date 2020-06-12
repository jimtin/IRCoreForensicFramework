function Remove-Target{
    <#
    .SYNOPSIS
        Removes a target from target list 
    .DESCRIPTION
        Removes a target from the target list
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string[]]$Target
    )

    # Iterate through the input target and setup sessions
    foreach ($endpoint in $Target){
        # Check if already in list
        if($GlobalTargetList.ContainsKey($endpoint)){
            # If yes, remove
            Remove-EndpointSession -Target $endpoint | Out-Null
            $message = "Target " + $endpoint + " removed"
        }else{
            $message = "Target " + $endpoint + " is not currently targeted"
        }

        # Inform user
        Write-HostHunterInformation -MessageData $message
    }

    # At the end of adding them all all, give the user a list of targets
    Get-TargetList

}