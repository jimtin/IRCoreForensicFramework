function Invoke-MemoryDump{
    <#
    .SYNOPSIS
    Invokes memory dump on a remote endpoint
    .DESCRIPTION
    Uses WinPmem 1.6.2 on the remote endpoint to dump memory into performance data
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)][System.Management.Automation.Runspaces.PSSession]$Target
    )

    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Invoke-MemoryDump"
        "DateTime" = (Get-Date).ToString()
        "Target" = $Target
    }

    # Set up the stopwatch variable to measure how long this takes
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Run command
    $memdump = Invoke-HostHunterCommand -Target $Target -ScriptBlock{
        # Create outcome dictionary
        $outcome = @{}

        # Get the timestamp of the command
        $outcome.Add("MemoryDumpTimestamp", (Get-Date).ToString())
        
        # Test for path
        $path = Test-Path -LiteralPath "C:\PerformanceInformation\mem_info.exe"
        $outcome.Add("PathExists", $path)

        # Confirm enough space exists on endpoint
        # Get the total physical memory size 
        $ramsize = [Math]::Round((Get-WmiObject -Class win32_computersystem -ComputerName localhost).TotalPhysicalMemory/1Gb)
        # Check that there is enough space on disk
        $disk = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" ).FreeSpace/1GB
        # Setup outcome
        $outcome.Add("MemorySize", $ramsize)
        $outcome.Add("FreeDiskSpace", $disk)

        if($disk -gt $ramsize){
            $outcome.Add("EnoughSpace", $true)
            if($path -eq $true){
                $memdump = C:\PerformanceInformation\mem_info.exe -o "C:\PerformanceInformation\memory.raw" --format raw --volume_format raw
                $outcome.Add("MemdumpInfo", $memdump)
            }
        }else{
            $outcome.Add("EnoughSpace", $false)
        }
        Write-Output $outcome
    }

    # Stop the stopwatch
    $stopwatch.Stop()
    
    # Add the timing to output
    $outcome.Add("TimeTaken", $stopwatch.Elapsed)

    # Add the outcome from the command to the outcome variable
    $outcome.Add("Outcome", $memdump)
        
    # Return the results to the user
    Write-Output $outcome
}