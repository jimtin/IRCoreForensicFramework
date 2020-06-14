using namespace System.Management.Automation
function Write-HostHunterInformation{
    <#
    .SYNOPSIS
        Writes messages to the information stream, optionally with
        color when written to the host.
    .DESCRIPTION
        An alternative to Write-Host which will write to the information stream
        and the host (optionally in colors specified) but will honor the
        $InformationPreference of the calling context.
        In PowerShell 5.0+ Write-Host calls through to Write-Information but
        will _always_ treats $InformationPreference as 'Continue', so the caller
        cannot use other options to the preference variable as intended.
        
        Full credit here: https://blog.kieranties.com/2018/03/26/write-information-with-colours
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][Object]$MessageData,
        [Parameter()][ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor, # Make sure we use the current colours by default
        [Parameter()][ConsoleColor]$BackgroundColor = $Host.UI.RawUI.BackgroundColor,
        [Parameter()][Switch]$NoNewline,
        [Parameter()][Switch]$ToolTipNotification,
        [Parameter()][string]$MessageTitle
    )

    if($ToolTipNotification){
        New-TooltipNotification -MessageData $MessageData -MessageTitle $MessageTitle
    }else {
        $msg = [HostInformationMessage]@{
            Message         = $MessageData
            ForegroundColor = $ForegroundColor
            BackgroundColor = $BackgroundColor
            NoNewline       = $NoNewline.IsPresent
        }
    
        Write-Information -InformationAction Continue -MessageData $msg
    }
    

}