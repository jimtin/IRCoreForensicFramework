function Import-VolatilitySymbols {
    <#
    .SYNOPSIS
    Imports the required symbol tables for Volatility3 from here: https://github.com/volatilityfoundation/volatility3

    .DESCRIPTION
    Imports the required symbol tables for volatility3. Used in this module as this is a large download and a bit different from standard executeable import
    #>
    [CmdletBinding()]
    param (
        
    )

    # Setup the file path
    $location = (Get-Location).ToString()
    $location = $location + "\PythonAnalysisList\volatility3\volatility\symbols\"
 
    #### Windows Symbol table
    # Test if windows path already exists
    $winloc = $location + "windows.zip"
    $windows = Test-Path -Path $winloc

    # If it does not exist, download
    if($windows -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Windows symbol tables for Volatility 3" -ForegroundColor "Yellow"
        $windownload = $location + "windows.zip"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip" -OutFile $windownload
    }

    Write-HostHunterInformation -MessageData "Windows Symbol Tables available" -ForegroundColor "Cyan"

    #### Mac Symbol tables
    # Test if Mac symbol tables already downloaded
    $macloc = $location + "mac.zip"
    $mac = Test-Path -Path $macloc

    # If it does not exist, download
    if($mac -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Mac symbol tables for Volatility 3" -ForegroundColor "Yellow"
        $macdownload = $location + "mac.zip"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip" -OutFile $macdownload
    }

    Write-HostHunterInformation -MessageData "Mac Symbol Tables available" -ForegroundColor "Cyan"

    #### Linux symbol tables
    # Test if Linux symbol tables already downloaded
    $linuxloc = $location + "linux.zip"
    $linux = Test-Path -Path $linuxloc

    if($linux -ne $true){
        Write-HostHunterInformation -MessageData "Downloading Linux symbol tables for Volatility 3" -ForegroundColor "Yellow"
        $linuxdownload = $location + "linux.zip"
        Invoke-WebRequest -Uri "https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip" -OutFile $linuxdownload
    }

    Write-HostHunterInformation -MessageData "Linux Symbol Tables available" -ForegroundColor "Cyan"

}