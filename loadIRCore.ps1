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
Write-HostHunterInformation -MessageData "Checking core executeables are downloaded"
Get-SetupExecuteables

# Set up the Python analysis folder
$analysis = Set-PythonAnalysisList
while($analysis -ne $true){
    Start-Sleep -Seconds 1
    $analysis = Set-PythonAnalysisList
}

# Copy Volatility into python analysis folder
Copy-Volatility

# Import Volatility3 Symbols tables for all operating systems
Write-HostHunterInformation -MessageData "Ensuring Volatility3 Symbols Tables are available"
Import-VolatilitySymbols

# Set up the target tracking variable
if((Get-Variable -Name GlobalTargetList -ErrorAction SilentlyContinue) -eq $null){
    New-Variable -Name "GlobalTargetList" -Scope global -Visibility Public -Value @{}
} 

Write-HostHunterInformation -MessageData "GlobalTargetList variable set" -ForegroundColor "Blue"

# Set up the global credential variable
if ($cred -eq $null){
    $cred = Get-Credential
    New-Variable -Name "cred" -Scope global -Visibility Public -Value $cred 
}
