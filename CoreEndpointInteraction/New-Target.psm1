function New-Target{
    <#
    .SYNOPSIS
        Creates a new target to be targeted 
    .DESCRIPTION
        Creates a new target to be targeted
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][string[]]$Target
    )

    # Confirm if creds variable is set
    if ($cred -eq $null){
        $cred = Get-Credential
    }

    # Iterate through the input target and setup sessions
    foreach ($endpoint in $Target){
        # Check if already in list
        if($GlobalTargetList.ContainsKey($endpoint)){
            $message = "Target " + $endpoint + " already exists"
            Write-HostHunterInformation -MessageData $message
        }else{
            $targets = $endpoint
            if($GlobalTargetList.Count -ge 1){
                # Extract each target name
                foreach($targettobeadded in $GlobalTargetList.Values){
                    Write-Host $targettobeadded.PSSession.ComputerName
                    $targets = $targets + "," + $targettobeadded.PSSession.ComputerName
                }

            }

            Write-Host $targets
            
            # Notify user
            $message = "Adding " + $endpoint + " to TrustedHosts list"
            Write-HostHunterInformation -MessageData $message -ForegroundColor "Green"

            # Set the trusted hosts registry key
            Set-Item WSMan:\localhost\Client\TrustedHosts $targets -Force

            # Now create the endpoint session
            New-EndpointSession -Target $endpoint -Credential $cred
        }
    }

    # At the end of adding them all all, give the user a list of targets
    Get-TargetList

}