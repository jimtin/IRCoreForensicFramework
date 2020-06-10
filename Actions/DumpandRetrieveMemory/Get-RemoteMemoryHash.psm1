function Get-RemoteMemoryHash {
    <#
    .SYNOPSIS
    Gets the SHA256 and MD5 hash of the remote memory dump

    .DESCRIPTION
    Gets the SHA256 and MD5 has of the remote memory dump. This hash is used to confirm the extracted memory dump matches the original
    
    #>
    param (
        [Parameter()]$Target = ""
    )

    # Set up the output dictionary
    $outcome = @{
        "HostHunterObject" = "Get-RemoteMemoryHash"
        "DateTime" = (Get-Date).ToString()
    }
    
    # Get a list of the sessions
    $sessions = Get-TargetSessions

    # If there is a target, reduce the sessions to that target
    if($Target -ne ""){
        $sessions = $sessions | Where-Object {$_.ComputerName -eq $Target}
    }

    # Hash values
    $hashvalues = @{}

    # Get the hashes for each session
    foreach($endpoint in $sessions){
        $target = $endpoint.ComputerName
        $remotehashvalues = Invoke-HostCommand -Targets $target -Scriptblock{
            # Set up the output variable
            $output = @{
                "Endpoint" = $env:COMPUTERNAME
                "DateTime" = (Get-Date).ToString()
            }

            # Get the SHA256 Hash
            $sha256hash = Get-FileHash -Path C:\PerformanceInformation\memory.raw -Algorithm SHA256
            $output.Add("SHA256Hash", $sha256hash)

            # Get the MD5 hash
            #$md5hash = Get-FileHash -Path C:\PerformanceInformation\memory.raw -Algorithm MD5
            #$output.Add("MD5Hash", $md5hash)

            # Return to the Invoke-HostCommand
            Write-Output $output
        }

        # Add the outcome to the HashValues dictionary
        $hashvalues.Add($Target, $remotehashvalues)
    }

    # Add the outcome of all the hash values to the output
    $outcome.Add("HashValues", $hashvalues)

    # Return to the user
    Write-Output $outcome

}