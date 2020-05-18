function Get-TargetList{
    <#
    .SYNOPSIS
        Gets a list of the current targets, and because it's fun prints them in red

    .DESCRIPTION
        Gets the private variable "GlobalTargetList" and prints a list of the endpoints being targeted
    #>
    param (
        
    )

    if ($GlobalTargetList -ne $null){
        $message = $GlobalTargetList.Keys
    }else{
        $message = "No Targets at this time"
    }
    
    Write-ColoredInformation -MessageData "Targets:" -ForegroundColor "Blue"
    Write-ColoredInformation -MessageData $message -ForegroundColor "Red"
    
}