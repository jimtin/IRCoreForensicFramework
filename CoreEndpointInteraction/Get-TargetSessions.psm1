function Get-TargetSessions{
    <#
    .SYNOPSIS
        Returns a list of the current sessions available

    .DESCRIPTION
        Returns a list of the current sessions available
    #>
    param (
        
    )

    # Set up the output variable
    $output = @()

    # Get a list of the keys in the GlobalTargetList
    $targets = Get-Variable -Name GlobalTargetList
    $endpoints = $targets.Value.keys

    # Get the associated sessions from the target list
    foreach ($target in $endpoints){
        # Get the associated session
        $session = $targets.Value[$target]["PSSession"]
        $output += $session
    }

    # Return the output to the user
    Write-Output $output

}