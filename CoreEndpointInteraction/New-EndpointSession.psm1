function New-EndpointSession{
    <#
    .SYNOPSIS
        Creates a new endpoint session
    .DESCRIPTION
        Creates a session on specified endpoint, updates the GlobalTargetList
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target, 
        [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credential
    )

    # Create output dictionary
    $output = @{
        "ObjectName" = "SessionCreated"
        "DateTime" = (Get-Date).ToString()
    }

    # Create the session depending on outcome
    try{
        $session = New-PSSession -ComputerName $Target -Credential $Credential -ErrorAction SilentlyContinue
        $output.Add("PSSession", $session)
        # Get some initial details about the endpoint
        $endpointdetails = Invoke-Command -Session $session -ScriptBlock{$env:COMPUTERNAME}
        $output.Add("EndpointDetails", $endpointdetails)
        # Add the new endpoint to GlobalTargetList
        $GlobalTargetList.Add($target, $output)
    }
    catch{
        $message = $target + " not created successfully"
        Write-HostHunterInformation -MessageData $message
    }    
    
}