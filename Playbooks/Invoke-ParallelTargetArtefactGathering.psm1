function Invoke-ParallelTargetArtefactGathering {
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

    Write-HostHunterInformation -MessageData "Invoking Artifact Gathering Playbook" -ForegroundColor "Green"

    # Set the target
    if($targets -eq ""){
        $targets = Get-TargetList
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

            # Get Windows Registry files
            $windowsregistry = Invoke-GetWindowsRegistry -Target $target
            $endpointoutcomes.Add("WindowsRegistry", $windowsregistry)

            # Get remote memory
            $remotememory = Invoke-GetRemoteMemory -Target $Target
            $endpointoutcomes.Add("WindowsRemoteMemory", $remotememory)


            Write-Output $endpointoutcomes
        } -ArgumentList $target, $cred

        $status = Get-Job $endpointjob.Id
        while ($status.State -ne "Completed") {
            $status = Get-Job $endpointjob.Id
        }

        # Notify user it's completed
        Write-HostHunterInformation -ToolTipNotification -MessageTitle $name -MessageData "Completed"

        Receive-Job -Id $endpointjob.Id -AutoRemoveJob -Wait
    }

}