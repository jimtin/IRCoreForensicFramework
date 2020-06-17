function Invoke-PlaybookCommand {
    <#
    .SYNOPSIS
    Invokes the HostCommand for playbooks, which means a job is not registered

    .DESCRIPTION
    Invokes the HostCommand specifically for playbooks. Used to prevent issues for future parallelisation.
    #>

    param (
        [Parameter(Mandatory=$true)]$Targets,
        [Parameter(Mandatory=$true)]$Scriptblock,
        [Parameter(Mandatory=$true)][System.Management.Automation.PSCredential]$Credentials
    )

    $HostHunterCommand = Invoke-HostCommand -Targets $Targets -Credential $Credentials -Scriptblock $Scriptblock -partofplaybook

    # Return output to pipeline
    Write-Output $HostHunterCommand
    
}