function Invoke-HostCommand{
    <#
    .SYNOPSIS
    Provides a mechanism to track and master the commands entered to remote endpoints

    .DESCRIPTION
    Complete alias for Invoke-Command using sessions
    
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Scriptblock,
        [Parameter()][switch]$RegisterCommand, 
        [Parameter()]$SimpleCommand,
        [Parameter()]$Targets="",
        [Parameter()][switch]$silent, 
        [Parameter()][switch]$partofplaybook,
        [Parameter()][switch]$notjob,
        [Parameter()][System.Management.Automation.PSCredential]$Credential
    )

    

    # Determine how command is to be run. Is this going to be a job, silent, part of a playbook etc
    if($partofplaybook){
        # A new session will need to be created
        $session = New-PSSession -ComputerName $Targets -Credential $cred
        # Take command and run it without piping it into a job
        $HostHunterCommand = Invoke-Command -Session $session -ScriptBlock $Scriptblock
    }elseif (notjob) {
        # Set up targets
        if($Targets -eq ""){
            # Get the current list of target powershell sessions
            $targets = Get-PSSession
        }else{
            $Targets = Get-PSSession | Where-Object {$_.ComputerName -eq $Targets}
        }

        # Run command without using a job
        $HostHunterCommand = Invoke-Command -Session $targets -ScriptBlock $Scriptblock
    }
    else{
        # Set up targets
        if($Targets -eq ""){
            # Get the current list of target powershell sessions
            $targets = Get-PSSession
        }else{
            $Targets = Get-PSSession | Where-Object {$_.ComputerName -eq $Targets}
        }
        # Take command and run as a job
        $HostHunterCommand = Invoke-Command -Session $targets -ScriptBlock $Scriptblock -AsJob 
        # Set up the SimpleCommand text for tooltip notification
        if($SimpleCommand -eq $null){
            $SimpleCommand = $Scriptblock.toString()
        }

        # If RegisterCommand switch selected, register the job
        if ($RegisterCommand){
            # Set up Message title
            $MessageTitle = $SimpleCommand + " Remote Job"
            # Update the message
            $Message = "Powershell job " + $SimpleCommand + " started"
            New-ToolTipNotification -MessageTitle $MessageTitle -MessageData $Message
            Register-ObjectEvent -InputObject $HostHunterCommand -EventName StateChanged -Action {
                if($sender.State -eq "Completed"){
                    $MessageTitle = $SimpleCommand + " Remote Job"
                    $global:RegisteredCommandOutput = Receive-Job -Id $sender.Id -AutoRemoveJob -Wait
                    $Message = "Powershell job " + $SimpleCommand + " completed"
                    New-TooltipNotification -MessageTitle $MessageTitle -Message $Message
                    $eventSubscriber | Unregister-Event
                    $eventSubscriber.Action | Remove-Job -Force
                }
            } | Out-Null
        }else{
            Do{
                $status = Get-Job -Id $HostHunterCommand.Id
                if($status.State -eq "Completed"){
                    # If completed, get the results
                    $output = Receive-Job -id $HostHunterCommand.Id
                    # Now delete the job as it is completed
                    Receive-Job -Job $HostHunterCommand -AutoRemoveJob -Wait
                    Write-Output $output
                    break
                }else{
                    if($silent){
                        
                    }else{
                        Write-HostHunterInformation -MessageData "Powershell job still running"
                    }
                    Start-Sleep -Seconds 1
                }
                
            }while ($true)
        }
    }

    
}