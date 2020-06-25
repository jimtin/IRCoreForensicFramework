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

# Rename the extracted HostHunter folder
RUN powershell Rename-Item -Path C:\\HostHunter\\IRCoreForensicFramework-master -NewName IRCoreForensicFramework

# Download HostHunter executables to the install directory
## WinPmem
ADD https://github.com/Velocidex/c-aff4/releases/download/v3.3.rc3/winpmem_v3.3.rc3.exe C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\WinPmem.exe
## Srum_Dump2
ADD https://github.com/MarkBaggett/srum-dump/blob/master/srum_dump2.exe C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\srum_dump2.exe
## SRUM Dump Template
ADD https://github.com/MarkBaggett/srum-dump/blob/master/SRUM_TEMPLATE2.xlsx C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\SRUM_TEMPLATE2.exe
## Volatility3
ADD https://github.com/volatilityfoundation/volatility3/archive/master.zip C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\volatility3.zip
## Prefetch Parser PECmd.zip
ADD https://f001.backblazeb2.com/file/EricZimmermanTools/PECmd.zip C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\PECmd.zip

# Create the Extraction Folder
RUN mkdir C://ExtractionDirectory

# Create the PythonAnalysisList folder
RUN mkdir C://HostHunter//IRCoreForensicFramework//PythonAnalysisList

# Expand Volatility
RUN powershell Expand-Archive -Path C:\\HostHunter\\IRCoreForensicFramework\\Executeables\\volatility3.zip C:\\HostHunter\IRCoreForensicFramework\\PythonAnalysisList

# Rename to volatility 3
RUN powershell Rename-Item -Path C:\\HostHunter\IRCoreForensicFramework\\PythonAnalysisList\\volatility3-master -NewName volatility3

# Delete the .github and development aspects of volatility3
RUN powershell Remove-Item -Path C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\.github -recurse
RUN powershell Remove-Item -Path C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\development -recurse
RUN powershell Remove-Item -Path C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\.gitignore

# Add in the symbols tables to volatility3
## Windows Symbols
ADD https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\volatility\\symbols\\windows.zip
## MacOS Symbols
ADD https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\volatility\\symbols\\mac.zip
## Linux Symbols
ADD https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip C:\\HostHunter\\IRCoreForensicFramework\\PythonAnalysisList\\volatility3\\volatility\\symbols\\linux.zip

# Install python
RUN C:\\python-3.8.3.exe /quiet InstallAllUsers=1 PrependPath=1

# Enable Powershell Remoting
RUN powershell Enable-PSRemoting -Force

# Set up the working directory
WORKDIR C:\\HostHunter\\IRCoreForensicFramework

# Upon start up, load HostHunter into memory space
#CMD pwsh C://HostHunter//IRCoreForensicFramework//loadIRCore.ps1