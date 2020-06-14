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
    $localdata = New-LocalDataStagingLocation
    

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
        $messagetitle = "Target: " + $target 
        $message = "Setting up remote staging location"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -TooltipNotification
        $staginglocation = New-RemoteStagingLocation -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteStagingOutcome", $staginglocation)
        

        # Move WinPMEM across
        $message = "Moving across WinPmem"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $winpmem = Move-WinPmem -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("WinPmemMoveOutcome", $winpmem)

        # Invoke dumping memory
        $message = "Dumping Memory"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $memdump = Invoke-MemoryDump -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("MemDumpOutcome", $memdump)
        
        # Due to the way commands work, confirm that the current session is not set to busy with another job
        $session = Get-PSSession | Where-Object {$_.ComputerName -eq $target}
        while ($session.Availability -ne "Available") {
            $message = "Remote Session " + $session.ComputerName + ": " + $session.Availability + " dumping memory"
            Start-Sleep -Seconds 2
            $session = Get-PSSession | Where-Object {$_.ComputerName -eq $target}
        }

        # Retrieve Memory
        $message = "Retrieving memory dump"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $memretrieve = Get-MemoryDump -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("MemDumpRetrieveOutcome", $memretrieve)

        # Get the dumped memory hash on the endpoint and extracted memory dump to ensure that nothing changed during extraction
        $message = "Comparing remote memory hash against collected memory hash"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $message = "Getting remote memory hash"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $remotehash = Get-RemoteMemoryHash
        $message = "Getting local memory hash"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $extractedhash = Get-ExtractedMemoryHash
        $hashcompare = Compare-MemoryHashes -RemoteMemoryHash $remotehash -LocalMemoryHash $extractedhash -Target $target
        if($hashcompare -eq $true){
            $message = "Memory hash comparison successful. Processing memory file"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
            # Process the memory dump
            $message = "Processing Memory Dump"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
            $message = "Volatility PSList module processing"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
            $PSList = Invoke-VolatilityPSList -Targets $target
            $endpointoutcomes.Add("VolatilityPSListOutcome", $PSList)
            $message = "Volatility PSScan module processing"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
            $PSScan = Invoke-VolatilityPSScan -Targets $target
            $endpointoutcomes.Add("VolatilityPsScanOutcome", $PSScan)
            $message = "Volatility Cmdline module processing"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
            $cmdline = Invoke-VolatilityCmdline -Targets $target
            $endpointoutcomes.Add("VolatilityCmdlineOutcome", $cmdline)
        }else{
            $message = "Endpoint " + $target +": Memory hash comparison failed. Memory file corrupted, try again"
            Write-HostHunterInformation -MessageData $message -ForegroundColor "Red"
        }
        
        # Copy EventLogs and SRU
        $message = "Getting event logging"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $copylogs = Copy-RemoteEventLogging -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteEventLogCopyOutcome", $copylogs)
        
        # Retrieve EventLogs and SRU
        $message = "Retrieving EventLogs and SRUDB"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $retrievelogs = Get-RemoteEventLogging -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("RemoteEventLogRetrievalOutcome", $retrievelogs)
        
        # Process the SRU 
        $message = "Formatting SRUDB"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $sruprocessing = Format-SRUDB -Target $target
        # Add outcome to endpointoutcomes variable
        $endpointoutcomes.Add("FormatSRUDBOutcome", $sruprocessing)

        # Remove the Remote Staging location from Target endpoint
        $message = "Removing remote staging location"
        Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -ToolTipNotification
        $remove = Remove-RemoteStagingLocation
        $endpointoutcomes.Add("RemoteStagingLocationOutcome", $remove)

        # Add all of these results to the output variable
        $output.Add($target, $endpointoutcomes)

    }
    
    # Return outcome to the user
    Write-Output $output
    
}