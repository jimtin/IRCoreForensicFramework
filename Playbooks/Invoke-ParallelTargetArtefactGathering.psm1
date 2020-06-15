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

    foreach($target in $targets){
        $name = $target + ": ArtefactCollectionPlaybook"

        # Set up the root for importing modules
        $env:WhereAmI = Get-Location
        Start-Job -Name $name -InitializationScript{
            # Get a list of all Host Hunter modules
            $content = Get-Content -Path "$env:WhereAmI\modulemanifest.txt"

            # Import into the current job
            foreach($cmdlet in $content){
                Import-Module $cmdlet -Force
            }

        } -ScriptBlock{
            # Create the endpoint dictionary
            $endpointoutcomes = @{
                "HostName" = $target
            }

            # Get the targets sessions from the session list
            $targetsession = Get-PSSession | Where-Object {$_.Name -eq $target}

            # Create the remote staging location
            $messagetitle = "Target: " + $target 
            $message = "Setting up remote staging location"
            Write-HostHunterInformation -MessageData $message -MessageTitle $messagetitle -TooltipNotification
            $staginglocation = New-RemoteStagingLocation -Target $target
            # Add outcome to endpointoutcomes variable
            $endpointoutcomes.Add("RemoteStagingOutcome", $staginglocation)
            Write-Output $staginglocation
        }
    }

}