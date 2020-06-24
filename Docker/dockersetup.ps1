#Requires -Version 7

# Set up the current working directory
$location = (Get-Location).tostring()

Write-Host $location

# Get a list of modules from the modules file 
$path = $location + "\modulemanifest.txt"
$modules = Get-Content -Path $path

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
$volatility = Copy-Volatility

# Import Volatility3 Symbols tables for all operating systems
Write-HostHunterInformation -MessageData "Ensuring Volatility3 Symbols Tables are available"
Import-VolatilitySymbols

# Make sure Prefetch Parser is ready
Expand-PrefetchParser

# Set up the target tracking variable
if((Get-Variable -Name GlobalTargetList -ErrorAction SilentlyContinue) -eq $null){
    New-Variable -Name "GlobalTargetList" -Scope global -Visibility Public -Value @{}
} 

Write-HostHunterInformation -MessageData "GlobalTargetList variable set" -ForegroundColor "Blue"

