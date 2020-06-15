function Copy-WindowsRegistry{
    <#
    .SYNOPSIS
    Copies Windows Registry hive from target endpoints

    .DESCRIPTION
    Copies the Windows Registry hive from target endpoint. Current registry hives targeted outlined below:
    1. 
    #>

    [CmdletBinding()]
    param (
        [Parameter()][string]$Target = "",
        [Parameter()][switch]$partofplaybook
    )

    # Set up the outcome variable
    $outcome = @{
        "HostHunterObject" = "Copy-WindowsRegistry"
        "DateTime" = (Get-Date).ToString()
    }

    # Set up the target list
    if($Target = ""){
        $target = Get-TargetList
    }

    if($partofplaybook){
        foreach($endpoint in $target){
            # Set up endpoint outcome
            $endpointoutcome = @{}
            $endpointoutcome.Add("PartofPlaybook", $true)
            $copylog = Invoke-PlaybookCommand -Targets $endpoint -Scriptblock{
                # Set up the output variable
                $Output = @{
                    "DateTime" = (Get-Date).ToString()
                }

                # Create a registry folder in PerformanceInformation
                $registry = New-Item -Path "C:\PerformanceInformation" -Name "Registry" -ItemType Directory
                $Output.Add("RegistryFolderCreated", $registry)

                # Use reg export to get HKCR 
                reg export HKCR C:\PerformanceInformation\Registry\HKCR.reg /y

                # Use reg export to get HKCU
                reg export HKCU C:\PerformanceInformation\Registry\HKCU.reg /y

                # Use reg export to get HKLM
                reg export HKLM C:\PerformanceInformation\Registry\HKLM.reg /y

                # Use reg export to get HKU
                reg export HKU C:\PerformanceInformation\Registry\HKU.reg /y

                # Use reg export to get HKCC
                reg export HKCC C:\PerformanceInformation\Registry\HKCC.reg /y
            }
            $endpointoutcome.Add("EndpointOutcome", $copylog)
            $outcome.Add($endpoint, $endpointoutcome)
        }
    }else{
        foreach($endpoint in $target){
            # Set up endpoint outcome
            $endpointoutcome = @{}
            $endpointoutcome.Add("PartofPlaybook", $false)
            $copylog = Invoke-HostCommand -Targets $endpoint -Scriptblock{
                # Set up the output variable
                $Output = @{
                    "DateTime" = (Get-Date).ToString()
                }

                # Create a registry folder in PerformanceInformation
                $registry = New-Item -Path "C:\PerformanceInformation" -Name "Registry" -ItemType Directory
                $Output.Add("RegistryFolderCreated", $registry)

                # Use reg export to get HKCR 
                reg export HKCR C:\PerformanceInformation\Registry\HKCR.reg /y
                $Output.Add("HKCR_Reg_Export_DateTime", (Get-Date).ToString())

                # Use reg export to get HKCU
                reg export HKCU C:\PerformanceInformation\Registry\HKCU.reg /y
                $Output.Add("HKCU_Reg_Export_DateTime", (Get-Date).ToString())

                # Use reg export to get HKLM
                reg export HKLM C:\PerformanceInformation\Registry\HKLM.reg /y
                $Output.Add("HKLM_Reg_Export_DateTime", (Get-Date).ToString())

                # Use reg export to get HKU
                reg export HKU C:\PerformanceInformation\Registry\HKU.reg /y
                $Output.Add("HKU_Reg_Export_DateTime", (Get-Date).ToString())

                # Use reg export to get HKCC
                reg export HKCC C:\PerformanceInformation\Registry\HKCC.reg /y
                $Output.Add("HKCC_Reg_Export_DateTime", (Get-Date).ToString())

                # Return outcome to command
                Write-Output $Output
            }
            $endpointoutcome.Add("EndpointOutcome", $copylog)
            $outcome.Add("TestOutcome", $endpointoutcome)
        }
    }

    # Return outcomes to users
    Write-Output $outcome

}