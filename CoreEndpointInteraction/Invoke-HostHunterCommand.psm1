function Invoke-HostHunterCommand {
    <#
    .SYNOPSIS
    Core of the endpoint interaction functions. Uses a combination of sessions, Invoke-Commands, jobs and so on to enable framework to operate at scale

    .DESCRIPTION
    To be updated
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Scriptblock, 
        [Parameter()]$Target
        # [Parameter()][System.Management.Automation.PSCredential]$Credential,
        # [Parameter()][switch]$playbookcommand
        # todo: DomainCommand variable
    )

    # Set up the output variable
    $output = @{
        "HostHunterObject" = "Invoke-HostHunterCommand"
        "DateTime" = (Get-Date).ToString()
        "CommandRun" = $Scriptblock
        "Target" = $Target
    }

    # Get the Data type of the connection
    $targetdatataype = $Target.GetType()
    $targetdatataype = $targetdatataype.Name
    $output.Add("TargetDataType", $targetdatataype)

    # If the data type is a PSSession, the command can be passed straight into the session. This reduces the number of forensic artefacts from the framework for forming new connections
    if($targetdatataype = "PSSession"){
        $runcommand = Invoke-Command -Session $Target -ScriptBlock $Scriptblock
        $output.Add("Outcome", $runcommand)
    }
    
    Write-Output $output
}