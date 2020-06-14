function New-TooltipNotification{
    <#
    .SYNOPSIS
        Pops a tooltip notification to a user when a job is completed

    .DESCRIPTION
        Pops a tooltip notification to a user when a job is completed. Code from here: 
        https://github.com/proxb/PowerShell_Scripts/blob/master/Invoke-BalloonTip.ps1
    #>

    [CmdletBinding()]
    param (
        [Parameter(HelpMessage="The message title")]$MessageTitle="HostHunter Update",
        [Parameter(HelpMessage="The body of text to be displayed in message")]$MessageData="Powershell job completed"
    )

    # Add the assembly name required for use
    Add-Type -AssemblyName System.Windows.Forms

    # Create global variable for the balloon
    If (-Not $Global:balloon){
        $Global:balloon = New-Object System.Windows.Forms.NotifyIcon

        # Set up a double click to dispose
        [void](Register-ObjectEvent -InputObject $balloon -EventName MouseDoubleClick -SourceIdentifier IconClicked -Action{
            # Clean up the balloon tip
            Write-Verbose "Disposing of Balloon"
            $Global:balloon.dispose()
            Unregister-Event -SourceIdentifier IconClicked
            Remove-Job -Name IconClicked
            Remove-Variable -Name balloon -Scope Global
        })
    }

    $SysTrayIconPath='C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'

    # Create Icon for the tray
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($SysTrayIconPath)

    $MessageType = "Info"
    # Set up tip text and icons
    $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]$MessageType
    $balloon.BalloonTipText  = $MessageData
    $balloon.BalloonTipTitle = $MessageTitle
    $balloon.Visible = $true

    # Display the tool tip and specify how many milliseconds it will stay visible for
    $balloon.ShowBalloonTip(5000)

    Write-Verbose "Ending Function"

}