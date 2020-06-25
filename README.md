# IRCoreForensicFramework
Powershell 7 (Powershell Core)/ C# cross platform forensic framework. Built by incident responders for incident responders. 

## Core Concepts
* Laser focused on automating incident response actions, rather than system monitoring. Aims to eliminate Tier I and Tier II adversaries described in the article *Resilient Military Systems and the Advanced Cyber Threat* (https://nsarchive2.gwu.edu/NSAEBB/NSAEBB424/docs/Cyber-081.pdf)
* Tightly controlled and well recorded interation with remote systems 
* Fun and interesting
* No need to use a host agent - this tool uses living off the land techniques, combined with the WinPmem executeable

## Setup (What you need to use if you don't want to use the docker image)
1. Your own endpoint with the following installed: 
    * Powershell Core 
    * Python 3.7 (minimum)
    * Plenty of storage space (I'd recommend at least 100Gb if you're looking to extract memory)
    * Plenty of processing power. (I'd recommend at least a 9th generation i5 or AMD equivalent). The framework makes extensive use of parallelization to operate at scale, so the more powerful the greater your reach will be. 
2. Reasonable Powershell experience. This program is currently in Beta, so there's likely to be a bit of interaction to use it.

## Setup (Docker)
1. Navigate to https://hub.docker.com/r/jimtin/hosthunter
2. Check out if this is what you're looking for and then download and use. Let me know how it goes if there's anything I can do to improve :) 

## How to use
1. Clone repository into your own directory
2. Open Powershell Core as administrator
3. Run the loadIRCore script. `.\loadIRCore.ps1` 
    * Note: If you are not an Administrator, you will be prompted to restart console as admin
    * This script will download a number of files for you. Take time to understand what is being downloaded. 
    * You will be prompted for credentials. 
4. Create a target: `New-Target -Target 127.0.0.1`
5. Start running commands against the target. Some examples:
    * Range of basic forensic artefacts on all targets: `Invoke-CoreForensicArtifactGatheringPlaybook`
    * Range of basic forensic artefacts on specific target: `Invoke-CoreForensicArtifactGatheringPlaybook -Target 127.0.0.1`
6. To process artefacts into JSON format:
    * After using the CoreForensicArtifactGathering Playbook: `Invoke-CoreForensicArtifactProcessingPlaybook`
    * After using the CoreForensicArtifactGathering Playbook, but processing a specific target: `Invoke-CoreForensicArtifactProcessingPlaybook -Target 127.0.0.1`

## Assumptions
* You have administrative access to your network 
* The access you use on your network is secure

## A cool example of what happens when you combine operational experience with engineering expertise to automate common Incident Response processes

### Playbook: Invoke-CoreForensicArtifactGatheringPlaybook
#### Overview
This playbook automates the gathering of core forensic artefacts. Moreover, it's simple to add more in if you need to. These artefacts are almost always asked for by incident reponders, yet no tool on the market does it as seamlessly as this.   

#### What it does
1. Records all actions it does, so that when you inevitably need to figure out what has happened on the endpoint, you know which actions were you and which were the adversaries. 
2. Creates a remote staging location, innocuously named "PerformanceInformation"
3. Pushes winpmem across to the remote endpoint
4. *Checks if there is enough space on the endpoint to dump memory*
5. Dumps memory
6. Extracts the following artefacts to your remote endpoint: 
    * Memory Dump (and confirms that the hash of what was dumped matches what actually ends up on your machine)
    * All the event logs (i.e. the entire event log folder, not just the event logs that some random engineering team thinks are what you need)
    * SRUM database (i.e. the forensic artifact which could allow you to a link a user, process and network activity together)
    * Key Registry hives
    * Prefetch Folder
    * Current running processes (for the inevitable question 'Was this process running when we touched this machine?')
7. Finishes up by going and deleting the Remote Staging location so that the endpoint doesn't get all clogged up by what you've done
8. Runs the entire process as Powershell Job, so can be mulithreaded. Registers the job with the native windows notification icon, so will simply notify you when completed

Pretty awesome. And it's just the start. Using this platform, significant post-processing is also available :) 

### Playbook: Invoke-CoreForensicArtifactProcessingPlaybook
#### Overview
This playbooks automatically processes all the artefacts gathered by the CoreForensicArtifactGatheringPlaybook. Naturally there will be times when not all artefacts are gathered, so this playbook processes what is available and continues onwards. Best of all, all artefacts are output in JSON so they can be easily uploaded to your SIEM of choice. 

#### What it does
1. Records all actions it does, so that when you inevitably need to figure out what has happened on the endpoint, you know which actions were you and which were the adversaries. 
2. Processes the following artefacts:
    * SRU Database, using Mark Baggerts srum_dump2
    * Prefetch, using Eric Zimmerman's PECmd
    * Volatility commands using Volatility3 
    * Some Windows EventLogs (with more being added) using my own custom processing
3. Outputs all results in JSON, into a folder title "ProcessedArtefacts"
4. Runs the entire process as Powershell Job, so can be mulithreaded. Registers the job with the native windows notification icon, so will simply notify you when completed

#### Some cool things
1. Makes use of the Windows ToolTip API. Combined with the use of jobs to multithread operations, this framework can gather these artefacts from multiple endpoints simultaneously. 
2. Means you can continue to do other actions while the time consuming actions (i.e. extracting memory) continue.
3. By using extensive use of living-off-the-land techniques, the artefacts left behind by this framework are minimal. Contrast this to many SOC tools and Incident Responders will appreciate the cleanliness of these actions. 

## Next steps
1. Integrate the ability to zip using native windows tools
2. Integrate the ability to automatically upload to cloud storage (likely Amazon s3)
3. Start doing some basic post-processing analysis to make IR jobs even easier
