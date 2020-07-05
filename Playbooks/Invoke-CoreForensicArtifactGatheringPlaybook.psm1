function Invoke-CoreForensicArtifactGatheringPlaybook {
    <#
    .SYNOPSIS
    This orchestration (powershell would call it a workflow, but Powershell 7 no longer supports workflows) gets the core forensic outputs from an endpoint

    .DESCRIPTION
    This orchestration module invokes the following modules to get core forensic artefacts
    1. Creates remote and local data staging locations
    2. Captures some current state details for later comparison
    3. Captures registry
    4. Captures eventlogs and the SRU database
    5. Dumps and extracts memory

    Can run on an arbitary number of remote machines, depending on disk space and network bandwidth

    #>
    [CmdletBinding()]
    param (
        [Parameter()]$targets=""
    )

    # Create output variable
    $output = @{
        "HostHunterObject" = "Invoke-CoreForensicArtifactGatheringPlaybook"
        "DateTimeCreated" = (Get-Date).ToString()
        "Target" = $targets
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
        # Set up the target name
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
            # Set up the stopwatch variable to measure how long this takes
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Create the endpoint outcomes
            $endpointoutcomes = @{
                "Target" = $args[0]
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

            # Get Windows prefetch information
            $prefetch = Invoke-GetWindowsPrefetch -Target $Target
            $endpointoutcomes.Add("Prefetch", $prefetch)

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

            # Stop the stopwatch
            $stopwatch.Stop()
            
            # Add the timing to output
            $endpointoutcomes.Add("TimeTaken", $stopwatch.Elapsed)

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

    # Return outcome to user
    Write-Output $output
}