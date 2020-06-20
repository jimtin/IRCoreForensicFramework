function Invoke-CoreForensicArtifactGatheringPlaybook {
    <#
    .SYNOPSIS
    This orchestration (powershell would call it a workflow, but Powershell 7 no longer supports workflows) gets the core forensic outputs from an endpoint

    .DESCRIPTION
    This orchestration module invokes the following modules to get core forensic artefacts
    1. New-LocalDataStagingLocation - Sets up the local datastaging location
    2. New-RemoteStagingLocation - On target list goes and creates a staging location
    3. Copy-RemoteEventLogging - Copies SRUDB and EventLogs to remote staging location
    4. Get-RemoteEventLogging - Gets the SRUDB and EventLogs
    5. Move-WinPMEM - Moves the winpmem executable across to remote endpoint ready for a remote memory dump
    6. Invoke-MemoryDump - Invokes a memory dump on the remote endpoint
    7. Get-MemoryDump - Gets a memory dump on the remote endpoint
    8. Format-SRUDB - Formats the SRUDB into a useable format
    9. Invoke-VolatilityCmdline - Processes the memory dump and extracts the cmdlines
    10. Invoke-VolatilityPSList - Processes the memory dump and extracts the PSList
    11. Invoke-VolatilityPSScan - Processes the memory dump and extracts the PSScan

    #>
    [CmdletBinding()]
    param (
        [Parameter()]$targets=""
    )

    # Create output variable
    $output = @{
        "Object" = "Invoke-TargetArtefactGathering"
        "DateTimeCreated" = (Get-Date).ToString()
    }

    # Set the target
    if($targets -eq ""){
        $targets = Get-TargetList
    }

    # Provide feedback to user on what is going to progress
    foreach($target in $targets){
        $message = "Invoking CoreForensicArtifactsGathering Playbook on: " + $target
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Green"
    }

    # Check that current endpoint has a local data staging location set up
    $localdata = New-LocalDataStagingLocation

    foreach($target in $targets){
        $name = $target + ": ArtefactCollectionPlaybook"
        
        # Notify the user that it's started
        Write-HostHunterInformation -ToolTipNotification -MessageTitle $name -MessageData "Started"

        # Set up the root for importing modules
        $env:WhereAmI = Get-Location
        $endpointjob = Start-Job -Name $name -InitializationScript{
            # Import the modules needed for this playbook
            $modulepath = $env:WhereAmI + "\Playbooks\artefactgatheringmodules.txt"
            $modules = Get-Content -Path $modulepath
            foreach($module in $modules){
                Import-Module $module
            }
        } -ScriptBlock{
            # Create the endpoint dictionary
            $endpointoutcomes = @{
                "HostName" = $args[0]
            }

            $target = $args[0]
            $cred = $args[1]

            # Create a new powershell session on the target. This is required as a Powershell Job is a brand new memory space
            $session = New-PSSession -ComputerName $target -Credential $cred
            $endpointoutcomes.Add("TargetSession", $session)

            # Convert the target variable into a session
            $target = $session

            # Create the staging location on the remote endpoint
            $remotedatastaginglocation = New-RemoteStagingLocation -Target $target
            $endpointoutcomes.Add("RemoteDataStaging", $remotedatastaginglocation)

            # Get current state details before being polluted with the rest of the artifact gathering
            $currentstate = Invoke-GetCurrentStateDetails -Target $target
            $endpointoutcomes.Add("CurrentState", $currentstate)

            # Get Windows Registry files
            $windowsregistry = Invoke-GetWindowsRegistry -Target $target
            $endpointoutcomes.Add("WindowsRegistry", $windowsregistry)

            # Get remote memory
            $remotememory = Invoke-GetRemoteMemory -Target $Target
            $endpointoutcomes.Add("WindowsRemoteMemory", $remotememory)

            # Get event logs and SRU
            $windowseventlogsandsru = Invoke-GetRemoteEventLogsandSRU -Target $target  
            $endpointoutcomes.Add("WindowsEventLogs", $windowseventlogsandsru)

            # Remove artifacts from remote endpoint
            $removal = Remove-RemoteStagingLocation -Target $target
            $endpointoutcomes.Add("RemoveStagingLocation", $removal)

            # Write the events undertaken to the folder
            Out-Events -Target $target -CommandHistory $endpointoutcomes

            Write-Output $endpointoutcomes
        } -ArgumentList $target, $cred 

        Register-ObjectEvent -InputObject $endpointjob -EventName StateChanged -MessageData $target -Action {
            if($sender.State -eq "Completed"){
                $target = ($sender.Name -split ":")[0]
                $name = $target + ": ArtefactCollectionPlaybook"
                
                # Notify the user that it's completed
                Write-HostHunterInformation -ToolTipNotification -MessageTitle $name -MessageData "Completed"
                
                # Receive the sending job and remove it from the list
                Receive-Job -Id $sender.Id -AutoRemoveJob -Wait

                # Unregister the event
                $eventSubscriber | Unregister-Event
                $eventSubscriber.Action | Remove-Job -Force
            }
        } | Out-Null

        
    }

}