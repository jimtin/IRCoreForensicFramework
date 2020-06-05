function Get-SetupExecuteables{
    <#
    .SYNOPSIS
        Gets several core executeables to enable generic IR Forensics to occur
    .DESCRIPTION
        Downloads core executeables
    #>

    [CmdletBinding()]
    param (
        
    )

    # Get the list of executeables to be downloaded
    $exelist = Get-Content -Path ".\Executeables\executeablemanifest.json" | ConvertFrom-Json

    foreach ($exe in $exelist){
        # Check if the executeable already exists
        $CurrentPath = (Get-Location).ToString()
        $fullpath = $CurrentPath + "\" + $exe.OutputPath + "\" + $exe.ExecutableName
        $exists = Test-Path -Path $fullpath
        if($exists -ne $true){
            Get-Executeable -DownloadURL $exe.DownloadURL -OutputLocation $exe.OutputPath -ExeName $exe.ExecutableName
        }else{
            $exe = ($exe.ExecutableName).ToString()
            $message = "Executeable for HostHunter available: " + $exe 
            Write-ColoredInformation -MessageData $message -ForegroundColor "Blue"
        }
    }
    
}