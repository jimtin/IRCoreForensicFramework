function Get-ExtractedMemoryHash {
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
        "HostHunterObject" = "Get-ExtractedMemoryHash"
        "DateTime" = (Get-Date).ToString()
    }

    # Filter for if target list is reduced
    if($Target -eq ""){
        $Target = Get-TargetList
    }

    # Hash values
    $hashvalues = @{}

    # Get the hashes for each session
    foreach($endpoint in $Target){
        # Construct the path where the hash will exist
        $path = "C:\ExtractionDirectory\" + $endpoint + "_ForensicArtifacts\memory.raw"

        # Add in the endpoint
        $hashoutput = @{
            "HostName" = $endpoint
        }

        # Get the SHA256 Hash
        $sha256hash = Get-FileHash -Path $path -Algorithm SHA256
        $hashoutput.Add("SHA256Hash", $sha256hash)

        # Get the MD5 hash
        $md5hash = Get-FileHash -Path $path -Algorithm MD5
        $hashoutput.Add("MD5Hash", $md5hash)

        # Add the outcome to the HashValues dictionary
        $hashvalues.Add($Target, $hashoutput)
    }

    # Add the outcome of all the hash values to the output
    $outcome.Add("HashValues", $hashvalues)

    # Return to the user
    Write-Output $outcome

}