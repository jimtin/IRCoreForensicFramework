function Invoke-HostCommand{
    <#
    .SYNOPSIS
        Provides a mechanism to track and master the commands entered to remote endpoints

    .DESCRIPTION
        Complete alias for Invoke-Command using sessions
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$Scriptblock
    )

    # Get the current list of target powershell sessions
    $targets = Get-TargetSessions

    # Take command and run as a job
    $CommandJob = Invoke-Command -Session $targets -ScriptBlock $Scriptblock -AsJob 
    Write-Host $CommandJob.id

    # Set up the wait variable
    $wait = 0

    # Get status. If not equal to completed, check if completed 5 times (5 more seconds)
    Do{
        $status = Get-Job -Id $CommandJob.Id
        if($status.State -eq "Completed"){
            Write-Host "Job completed"
            # If completed, get the results
            $output = Receive-Job -id $CommandJob.Id
            # Now delete the job as it is completed
            Receive-Job -Job $CommandJob -AutoRemoveJob -Wait
            Write-Output $output
            break
        }else{
            Write-ColoredInformation -Message "Powershell job still running"
        }
        $wait += 1
        Start-Sleep -Seconds 1
    }while ($wait -lt 5)

    # If not completed, register the event and return prompt to user. This allows actions to continue.
    # The input object for the event is the $CommandJob
    # Register the event job
    Register-ObjectEvent -InputObject $CommandJob -EventName StateChanged -Action {
        if($sender.State -eq "Completed"){
            $global:testoutput = Receive-Job -Id $sender.Id -AutoRemoveJob -Wait
            New-TooltipNotification
            $message = "Job ID " + $sender.Id + " using command " + $sender.Command + " is completed"
            Write-Host $message  
        }
    }

}