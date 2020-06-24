# Set the base image to be Microsoft provided Powershell Core image
FROM mcr.microsoft.com/powershell

# Set up some environment variables. Credit to Jung-Hyun Nam https://medium.com/rkttu/creating-python-docker-image-for-windows-nano-server-151e1ab7188a
ENV PYTHON_VERSION 3.8.3

# Change the shell to be powershell by default
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# Add in Python
ADD https://www.python.org/ftp/python/3.8.3/python-3.8.3-amd64.exe /python-3.8.3.exe

# Add in HostHunter
ADD https://github.com/jimtin/IRCoreForensicFramework/archive/master.zip /HostHunter.zip

# Expand the HostHunter zip
RUN powershell Expand-Archive -Path C:\\HostHunter.zip -Destination C:\\HostHunter

# Install all the executable files and symbol tables
RUN powershell C:\\HostHunter\\IRCoreForensicFramework-master\\Docker\\dockersetup.ps1

# Change permissions to be an administrator
USER ContainerAdministrator

# Run initial HostHunter loadIRCore to confirm all the executeables are loaded
#RUN powershell Get-Content C:\\HostHunter

# Install python
RUN C:\\python-3.8.3.exe /quiet InstallAllUsers=1

# Extract the HostHunter zip
#CMD powershell C:\\HostHunter\\loadIRCore.ps1

# Set up the working directory
WORKDIR C:\\HostHunter\\IRCoreForensicFramework-master

