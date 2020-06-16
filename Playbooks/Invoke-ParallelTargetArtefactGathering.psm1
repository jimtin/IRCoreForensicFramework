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

    Write-HostHunterInformation -MessageData "Invoking Artifact Gathering Playbook" -ForegroundColor "Red"

    # Set the target
    if($targets -eq ""){
        $targets = Get-TargetList
    }


    # Check that current endpoint has a local data staging location set up
    $localdata = New-LocalDataStagingLocation

    foreach($target in $targets){
        $name = $target + ": ArtefactCollectionPlaybook"

        # Create the storage location
        New-EndpointForensicStorageLocation -Target $target | Out-Null

        # Set up the root for importing modules
        $env:WhereAmI = Get-Location
        Start-Job -Name $name -InitializationScript{
            $module = $env:WhereAmI + "\Actions\WindowsRegistry\Copy-WindowsRegistry.psm1"
            Import-Module $module
            $module = $env:WhereAmI + "\Actions\WindowsRegistry\Get-WindowsRegistryFiles.psm1"
            Import-Module $module
            $module = $env:WhereAmI + "\Actions\WindowsRegistry\Invoke-GetWindowsRegistry.psm1"
            Import-Module $module
        } -ScriptBlock{
            # Create the endpoint dictionary
            $endpointoutcomes = @{
                "HostName" = $args[0]
            }

            $target = $args[0]

            Write-Host "Getting information from " + $target

            # Create the remote staging location
            # todo

            # Get Windows Registry files
            Copy-WindowsRegistry -Target $target
            #$windowsregistry = Invoke-GetWindowsRegistry -Target $target

            #Write-Output $windowsregistry
        } -ArgumentList $target
    }

}