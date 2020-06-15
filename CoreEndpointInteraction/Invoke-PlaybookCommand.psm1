function Invoke-PlaybookCommand {
    <#
    .SYNOPSIS
    Invokes the HostCommand for playbooks, which means a job is not registered

    .DESCRIPTION
    Invokes the HostCommand specifically for playbooks. Used to prevent issues for future parallelisation.
    #>

    param (
        [Parameter()]$Targets="",
        [Parameter(Mandatory=$true)]$Scriptblock
    )

    $HostHunterCommand = Invoke-HostCommand -Targets $Targets -Scriptblock $Scriptblock -partofplaybook

    # Return output to pipeline
    Write-Output $HostHunterCommand
    
}