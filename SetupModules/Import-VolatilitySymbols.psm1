function Import-VolatilitySymbols {
    <#
    .SYNOPSIS
    Imports the required symbol tables for Volatility3 from here: https://github.com/volatilityfoundation/volatility3

    .DESCRIPTION
    Imports the required symbol tables for volatility3. Used in this module as this is a large download and a bit different from standard executeable import
    #>
    param (
        
    )
 
    #### Windows Symbol table
    # Test if windows path already exists
    $windows = Test-Path -Path "\PythonAnalysisList\volatility3\volatility\symbols\windows"

    # If it does not exist, download
    if($windows -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Windows symbol tables for Volatility 3" -ForegroundColor "Yellow"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip" -OutFile "\PythonAnalysisList\volatility3\volatility\symbols\windows.zip"
    }

    #### Mac Symbol tables
    # Test if Mac symbol tables already downloaded
    $mac = Test-Path -Path "\PythonAnalysisList\volatility3\volatility\symbols\mac"

    # If it does not exist, download
    if($mac -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Mac symbol tables for Volatility 3" -ForegroundColor "Yellow"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip" -OutFile "\PythonAnalysisList\volatility3\volatility\symbols\mac.zip"
    }

    #### Linux symbol tables
    # Test if Linux symbol tables already downloaded
    $linux = Test-Path -Path "\PythonAnalysisList\volatility3\volatility\symbols\linux"

    if($mac -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Linux symbol tables for Volatility 3" -ForegroundColor "Yellow"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip" -OutFile "\PythonAnalysisList\volatility3\volatility\symbols\linux.zip"
    }

}