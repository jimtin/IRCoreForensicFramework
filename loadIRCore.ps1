#Requires -Version 7
#Requires -RunAsAdministrator

# Get a list of modules from the modules file 
$modules = Get-Content -Path .\modulemanifest.txt

foreach ($cmdlet in $modules){
    $messagestring = "Importing cmdlet: " + $cmdlet
    Write-Information -InformationAction Continue -MessageData $messagestring
    # Import the module
    Import-Module -Name $cmdlet -Force
}

# Ensure executables which will help are downloaded 
Write-Information -InformationAction Continue -MessageData "Checking core executeables are downloaded"
Get-SetupExecuteables

# Set up the target tracking variable
if((Get-Variable -Name GlobalTargetList -ErrorAction SilentlyContinue) -eq $null){
    New-Variable -Name "GlobalTargetList" -Scope global -Visibility Public -Value @{}
} 

Write-ColoredInformation -MessageData "GlobalTargetList variable set" -ForegroundColor "Blue"

# Set up the global credential variable
if ($cred -eq $null){
    $cred = Get-Credential
    New-Variable -Name "cred" -Scope global -Visibility Public -Value $cred 
}

# Check if snek is installed
$snek = Get-InstalledModule -Name snek -ErrorAction SilentlyContinue
if(-not $snek){
    Write-ColoredInformation -MessageData "Snek not installed, prompting for install now" -ForegroundColor "Red"
    Install-Module -Name snek
}else{
    Write-ColoredInformation -MessageData "Snek installed" -ForegroundColor "Blue"
}
