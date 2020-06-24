function Update-Credentials {
    <#
    .SYNOPSIS
    Updates the global credential variable with new credentials

    .DESCRIPTION
    Updates the global credential variable with new credentials
    
    #>
    param (
        
    )

    $cred = Get-Credential
    New-Variable -Name "cred" -Scope global -Visibility Public -Value $cred 
    
}