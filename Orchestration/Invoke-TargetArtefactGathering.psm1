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
    }

    # Get a list of the sessions
    $sessions = Get-TargetSessions

    # Set the target
    if($targets -eq ""){
        $targets = Get-TargetList
    }else{
        # Set the sessions variable to only be the the target session
        $sessions = $sessions | Where-Object {$_.ComputerName -eq $targets}
    }

    # Check that current endpoint has a local data staging location set up
    New-LocalDataStagingLocation

    # Now set off the orchestration. Make sure it is inherently parallelized
    ForEach-Object -InputObject $sessions -Parallel{
        # Get the session
        $sesh = $_

        # Get the target name
        $target = $sesh.ComputerName

        # Get a list of modules
        $modules = Get-Content .\modulemanifest.txt
        #foreach($module in $modules){
        #    Import-Module -Name $module -Force
        #}

        #Import-Module -Name .\Actions\CreateStagingLocation\New-RemoteStagingLocation.psm1 -Force
        Import-Module -Name .\CoreEndpointInteraction\Invoke-HostCommand.psm1 -Force
        Import-Module -Name .\CoreEndpointInteraction\Get-TargetSessions.psm1

        Invoke-HostCommand -Targets "192.168.20.25" -Scriptblock{Get-Process}

        # Create the remote staging location
        #$staginglocation = New-RemoteStagingLocation -Target $target
    }

    
}