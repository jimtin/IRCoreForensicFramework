function Invoke-HostCommand{
    <#
    .SYNOPSIS
        Provides a mechanism to track and master the commands entered to remote endpoints

    .DESCRIPTION
        Complete alias for Invoke-Command using sessions
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Command
    )

    # Setup the output dictionary
    $output = @{

    }

    # Get the current list of targets from global variable
    # Process flow. Run it as a job, wait for results, return results back to terminal. Offers some interesting possibilities
    $targets 

}