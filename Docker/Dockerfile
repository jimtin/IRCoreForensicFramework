# Set the base image to be Microsoft provided Powershell Core image
FROM mcr.microsoft.com/powershell:7.0.2-windowsservercore-1909

# Set up some environment variables. Credit to Jung-Hyun Nam https://medium.com/rkttu/creating-python-docker-image-for-windows-nano-server-151e1ab7188a
ENV PYTHON_VERSION 3.8.3

# Change the shell to be powershell by default
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop';"]

# Add in Python
ADD https://www.python.org/ftp/python/3.8.3/python-3.8.3-amd64.exe /python-3.8.3.exe

# Add in HostHunter
ADD https://github.com/jimtin/IRCoreForensicFramework/archive/master.zip /HostHunter.zip

# Expand the HostHunter zip
RUN powershell Expand-Archive -Path C:\\HostHunter.zip -Destination C:\\HostHunter

# Check powershell version
RUN powershell Write-Host $psversiontable.PSVersion

# Download HostHunter executables to the install directory
## WinPmem
ADD https://github.com/Velocidex/c-aff4/releases/download/v3.3.rc3/winpmem_v3.3.rc3.exe C:\\HostHunter\\IRCoreForensicFramework-master\\Executeables\\WinPmem.exe
## Srum_Dump2
ADD https://github.com/MarkBaggett/srum-dump/blob/master/srum_dump2.exe C:\\HostHunter\\IRCoreForensicFramework-master\\Executeables\\srum_dump2.exe
## SRUM Dump Template
ADD https://github.com/MarkBaggett/srum-dump/blob/master/SRUM_TEMPLATE2.xlsx C:\\HostHunter\\IRCoreForensicFramework-master\\Executeables\\SRUM_TEMPLATE2.exe
## Volatility3
ADD https://github.com/volatilityfoundation/volatility3/archive/master.zip C:\\HostHunter\\IRCoreForensicFramework-master\\Executeables\\volatility3.zip
## Prefetch Parser PECmd.zip
ADD https://f001.backblazeb2.com/file/EricZimmermanTools/PECmd.zip C:\\HostHunter\\IRCoreForensicFramework-master\\Executeables\\PECmd.zip

# Run initial HostHunter loadIRCore to confirm all the executeables are loaded
#RUN powershell Get-Content C:\\HostHunter

# Install python
RUN C:\\python-3.8.3.exe /quiet InstallAllUsers=1

# Extract the HostHunter zip
#CMD powershell C:\\HostHunter\\loadIRCore.ps1

# Set up the working directory
WORKDIR C:\\HostHunter\\IRCoreForensicFramework-master

