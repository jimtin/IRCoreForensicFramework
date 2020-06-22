function Invoke-CoreForensicArtifactProcessingPlabook {
    <#
    .SYNOPSIS
    Processes all available forensic artifacts collected by the CoreForensicArtifactGathering Playbook

    .DESCRIPTION
    Processes all available forensic artifacts collected by the CoreForensicArtifactGathering Playbook

    #>
    [CmdletBinding()]
    param (
        [Parameter()]$Target = ""
    )
    
    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-CoreForensicArtifactProcessingPlabook"
        "DateTime" = (Get-Date).ToString()
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # If a specific endpoint is not requested, get targets from the ExtractionDirectory
    if($Target -eq ""){
        # Declare $target as an array
        $target = @()

        # Get the directories under C:\ExtractionDirectory
        $endpoints = Get-ChildItem -Path C:\ExtractionDirectory

        # Get the Target name from the Command History file. If this doesn't exist, this playbook cannot be used
        foreach($computer in $endpoints){
            # Construct the path
            $commandhistorypath = "C:\ExtractionDirectory\" + $computer.Name + "\RemoteEndpointCommandHistory\RemoteEndpointCommandHistory.json"
            
            # Test if it exists
            $path = Test-Path -Path $commandhistorypath
            
            # If it exists, extract the Target and create a processed artefacts folder
            if($path -eq $true){
                $targetinfo = Get-Content -Path $commandhistorypath | ConvertFrom-Json
                $target += $targetinfo.Target
                New-ProcessedArtefactsStagingLocation -Target $targetinfo.Target
            }
        }
    }else {
        # Simply create the processed artefact staging location
        New-ProcessedArtefactsStagingLocation -Target $Target
    }

    # For each target, start a job
    foreach($endpoint in $Target){
        # Set up the environment variable to declare root directory
        $env:WhereAmI = Get-Location

        # Set up the name of the job
        $name = $Target + ": ArtefactProcessingPlaybook"

        # Notify user in commandline
        $message = $name + " started. Job registered."
        Write-HostHunterInformation -MessageData $message -ForegroundColor "Green"

        # Notify user that job has started
        Write-HostHunterInformation -ToolTipNotification -MessageTitle $name -MessageData "Started"

        # Convert to a string
        $name = $name.tostring()

        # Start the job
        $artefactprocessing = Start-Job -Name $name -InitializationScript{
            # Import the modules needed for this playbook
            $modulepath = $env:WhereAmI + "\Playbooks\artefactprocessingmodules.txt"
            $modules = Get-Content -Path $modulepath
            foreach($module in $modules){
                Import-Module $module
            }
        } -ScriptBlock{
            # Create the endpoint outcomes dictionary
            $endpointoutcomes = @{
                "Target" = $args[0]
            }

            # Set up the stopwatch variable to measure how long this takes
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

            # Set up the target
            $target = $args[0]

            # Get the outcome from the ArtifactGathering Process
            $artifactgatheringoutcomes = "C:\ExtractionDirectory\" + $target + "_ForensicArtifacts\RemoteEndpointCommandHistory\RemoteEndpointCommandHistory.json"
            $targetinfo = Get-Content $artifactgatheringoutcomes | ConvertFrom-Json

            # If remote srudb successful, process it
            if($targetinfo.WindowsEventLogs.EventLogExtraction.SRUExtractionOutcome -eq $true){
                # Depending on if registry hive successfully extracted, process SRU DB
                if($targetinfo.WindowsRegistry.GetWindowsRegistryFiles.SoftwareRegistryHive -eq $true){
                    $sruformat = Format-SRUDBtoJson -Target $target -registryexists
                }else {
                    $sruformat = Format-SRUDBtoJSON -Target $target
                }
                
                # Add outcome to endpoint outcomes
                $endpointoutcomes.Add("SRUProcessed", $sruformat)
            }

            # If getting event logs is successful, process them
            if($targetinfo.WindowsEventLogs.EventLogExtraction.EventLogExtractionOutcome -eq $true){
                $eventlogs = Invoke-EventLogProcessing -Target $target
                $endpointoutcomes.Add("EventLogProcessing", $eventlogs)
            }

            # If getting prefetch was successful, process this
            if($targetinfo.Prefetch.PrefetchGetOutcome.PrefetchExtractionOutcome -eq $true){
                $prefetch = Format-WindowsPrefetch -Target $target
                $endpointoutcomes.Add("Prefetch", $prefetch)
            }

            # If getting windows memory was successful, process this
            if($targetinfo.WindowsRemoteMemory.MemoryDumpRetrieved -eq $true){
                $memoryprocessing = Invoke-WindowsMemoryImageProcessing -Target $target
                $endpointoutcomes.Add("MemoryProcessing", $memoryprocessing)
            }

            # Stop the stopwatch
            $stopwatch.Stop()
            
            # Add the timing to output
            $endpointoutcomes.Add("TimeTaken", $stopwatch.Elapsed)

            # Return outcome to user
            Write-Output $endpointoutcomes
        } -ArgumentList $endpoint

        Register-ObjectEvent -InputObject $artefactprocessing -EventName StateChanged -MessageData $target -Action {
            if($sender.State -eq "Completed"){
                $target = ($sender.Name -split ":")[0]
                $name = $target + ": ArtefactProcessingPlaybook"
                
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

    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add the results to outcome dictionary
    $outcome.Add("EndpointOutcomes", $pathexists)
    
    # Return results to pwsh
    #Write-Output $outcome
}