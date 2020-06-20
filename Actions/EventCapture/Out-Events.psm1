function Out-Events {
    <#
    .SYNOPSIS
    Writes the events undertaken on a remote endpoint to specified location

    .DESCRIPTION
    Writes the events undertaken on a remote endpoint to specified location

    #>
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target,
        [Parameter(Mandatory=$true)]$CommandHistory
    )

    # Set up outcome
    $outcome = @{
        "HostHunterObject" = "Out-Events"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Test if RemoteEndpointCommandHistory folder exists. If not, create
    $Location = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts"
    $fulllocation = "C:\ExtractionDirectory\" + $Target.ComputerName + "_ForensicArtifacts\RemoteEndpointCommandHistory"
    $path = Test-Path -LiteralPath $fulllocation
    if($path -ne $true){
        New-Item -Path $Location -Name RemoteEndpointCommandHistory -ItemType Directory
    }

    # Take the incoming powershell object, turn it into JSON
    $outfile = $fulllocation + "\RemoteEndpointCommandHistory.json"
    $CommandHistory | ConvertTo-Json | Out-File $outfile

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Return the outcome to the user
    Write-Output $outcome
}