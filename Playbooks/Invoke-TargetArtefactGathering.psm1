function Invoke-TargetArtefactGathering {
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
    
    param (
        $targets=""
    )

    # Create output variable
    $output = @{
        "Object" = "Invoke-TargetArtefactGathering"
        "DateTimeCreated" = (Get-Date).ToString()
    }

    Write-HostHunterInformation -MessageData "Invoking Artifact Gathering Playbook" -ForegroundColor "Red"

    # Set the target
    if($targets -eq ""){
        $targets = Get-TargetList
    }

    # Check that current endpoint has a local data staging location set up
    New-LocalDataStagingLocation
    

    # Now set off the orchestration.
    foreach($target in $targets){
        # Create the endpoint dictionary
        $endpointoutcomes = @{
            "HostName" = $target
        }

        # Get the targets sessions from the session list
        $targetsession = Get-TargetSessions 
        $targetsession = $targetsession | Where-Object {$_.ComputerName -eq $target}

        # Create the remote staging location
        $message = "Endpoint " + $target +": Setting up remote staging location"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $staginglocation = New-RemoteStagingLocation -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteStagingOutcome", $staginglocation)
        

        # Move WinPMEM across
        $message = "Endpoint " + $target +": Moving across WinPmem"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $winpmem = Move-WinPmem -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("WinPmemMoveOutcome", $winpmem)
        

        # Invoke dumping memory
        $message = "Endpoint " + $target +": Dumping Memory"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $memdump = Invoke-MemoryDump -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("MemDumpOutcome", $memdump)
        
        # Due to the way commands work, confirm that the current session is not set to busy with another job
        $session = Get-PSSession | Where-Object {$_.ComputerName -eq $target}
        while ($session.Availability -ne "Available") {
            $message = "Remote Session " + $session.ComputerName + ": " + $session.Availability + " dumping memory"
            Write-HostHunterInformation -MessageData $message
            Start-Sleep -Seconds 2
            $session = Get-PSSession | Where-Object {$_.ComputerName -eq $target}
        }

        # Retrieve Memory
        $message = "Endpoint " + $target +": Retrieving memory dump"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $memretrieve = Get-MemoryDump -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("MemDumpRetrieveOutcome", $memretrieve)
        

        # Copy EventLogs and SRU
        $message = "Endpoint " + $target +": Getting event logging"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $copylogs = Copy-RemoteEventLogging -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteEventLogCopyOutcome", $copylogs)
        

        # Retrieve EventLogs and SRU
        $message = "Endpoint " + $target +": Retrieving EventLogs and SRUDB"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $retrievelogs = Get-RemoteEventLogging -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteEventLogRetrievalOutcome", $retrievelogs)
        

        # Process the SRU 
        $message = "Endpoint " + $target +": Formatting SRUDB"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $sruprocessing = Format-SRUDB -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("FormatSRUDBOutcome", $sruprocessing)
        

        # Process the memory dump
        $message = "Endpoint " + $target +": Processing Memory Dump"
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Cyan"
        $PSList = Invoke-VolatilityPSList -Targets $target
        $endpointoutcomes.Add("VolatilityPSListOutcome", $PSList)
        $PSScan = Invoke-VolatilityPSScan -Targets $target
        $endpointoutcomes.Add("VolatilityPsScanOutcome", $PSScan)
        $cmdline = Invoke-VolatilityCmdline -Targets $target
        $endpointoutcomes.Add("VolatilityCmdlineOutcome", $cmdline)

        # Add all of these results to the output variable
        $output.Add($target, $endpointoutcomes)

    }
    
    # Return outcome to the user
    Write-Output $output
    
}