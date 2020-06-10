function Remove-RemoteStagingLocation{
    <#
    .SYNOPSIS
    Removes the remote staging location from remote endpoint(s)

    .DESCRIPTION
    Removes the remote staging location from remote endpoint(s)
    Pairs with New-RemoteStagingLocation module
    
    #>
    [CmdletBinding()]
    param (
        [Parameter()]$Target = ""
    )

    # Set up outcome variable
    $outcome = @{
        "HostHunterObject" = "Remove-RemoteStagingLocation"
        "StagingLocation" = "C:\PerformanceInformation"
        "DateTime" = (Get-Date).ToString()
    }

    # If a target specified, use this, else do all
    if($Target -eq ""){
        # Test the endpoint to see if the Performance Information folder exists. If it does, remove recursively
        $pathexists = Invoke-HostCommand -ScriptBlock{
            # Set up output dictionary
            $output = @{}
            # Get Hostname of the command being run
            $output.Add("HostName", $env:COMPUTERNAME)
            # Test for the path
            $outcome = Test-Path -Path "C:\PerformanceInformation"
            # If outcome is true, remove the directory
            if($outcome -eq $true){
                $output.Add("RemovedPerformanceInformationFolderTimestamp", (Get-Date).ToString())
                Remove-Item -Path "C:\PerformanceInformation" -Recurse
            }
            # Record outcome for posterity
            $output.Add("Outcome", $outcome)
            Write-Output $output
        }

        # Add the results to outcome dictionary
        $outcome.Add("EndpointOutcomes", $pathexists)
    }else{
        # Test the endpoint to see if the Performance Information folder exists. If it does, remove recursively
        $pathexists = Invoke-HostCommand -ScriptBlock{
            # Set up output dictionary
            $output = @{}
            # Get Hostname of the command being run
            $output.Add("HostName", $env:COMPUTERNAME)
            # Test for the path
            $outcome = Test-Path -Path "C:\PerformanceInformation"
            # If outcome is true, remove the directory
            if($outcome -eq $true){
                $output.Add("RemovedPerformanceInformationFolderTimestamp", (Get-Date).ToString())
                Remove-Item -Path "C:\PerformanceInformation" -Recurse
            }
            # Record outcome for posterity
            $output.Add("Outcome", $outcome)
            Write-Output $output
        }

        # Add the results to outcome dictionary
        $outcome.Add("EndpointOutcomes", $pathexists)
    }
    
    # Return results to pwsh
    Write-Output $outcome
}