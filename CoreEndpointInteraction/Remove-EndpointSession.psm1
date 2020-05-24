function Remove-EndpointSession{
    <#
    .SYNOPSIS
        Creates a new endpoint session
    .DESCRIPTION
        Creates a session on specified endpoint, updates the GlobalTargetList
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Target
    )

    # Create output dictionary
    $output = @{
        "ObjectName" = "SessionRemoved"
        "DateTime" = (Get-Date).ToString()
        "Outcome" = "Failed"
    }

    # Find the session in the GlobalTargetList
    $contains = $GlobalTargetList.Contains($Target)
    # If the session exists, be awesome, close the session down then remove from the GlobalTargetList
    if($contains -eq $true){
        Remove-PSSession -Name $Target 
        $output.Add("Endpoint", $Target)
        $GlobalTargetList.Remove($Target)
        $output.Outcome = "Success"
    }else{
        $message = $Target + " Endpoint does not exist in target list"
        Write-Information -InformationAction Continue -MessageData $message
        $output.Outcome = "DoesNotExist"
    }

    Write-Output $output

}