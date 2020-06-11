# IRCoreForensicFramework
Powershell 7 (Powershell Core)/ C# based cross platform forensic framework. Built by incident responders for incident responders. 

## Core Concepts
* Laser focused on automating incident response actions, rather than system monitoring. Aims to eliminate Tier I and Tier II adversaries described in the article *Resilient Military Systems and the Advanced Cyber Threat* (https://nsarchive2.gwu.edu/NSAEBB/NSAEBB424/docs/Cyber-081.pdf)
* Tightly controlled and well recorded interation with remote systems 
* Fun and interesting

## Setup (What you need to use)
1. Your own endpoint with the following installed: 
    * Powershell Core 
    * Python 3.7 (minimum)
    * Plenty of storage space (I'd recommend at least 100Gb if you're looking to extract memory)
    * Plenty of processing power. (I'd recommend at least a 9th generation i5 or AMD equivalent)
2. Reasonable Powershell experience. This program is currently in Beta, so there's likely to be a bit of interaction to use it.

## How to use
1. Clone repository into your own directory
2. Open Powershell Core as administrator
3. Run the loadIRCore script. `.\loadIRCore.ps1` 
    * Note: If you are not an Administrator, you will be prompted to restart console as admin
    * This script will download a number of files for you. Take time to understand what is being downloaded. 
    * You will be prompted for credentials. 
4. Create a target: `New-Target -Target 127.0.0.1`
5. Start running commands against the target. For instance if you want to get a range of basic forensic artifacts, try the Playbook TargetArtefactGathering: `Invoke-TargetArtefactGathering`

## A cool example of what happens when you combine operational experience with engineering expertise to automate common Incident Response Processes

### Playbook: Invoke-TargetArtefactGathering
#### Overview
This playbook takes one of the most common and frustrating experiences with Incident Response and automates the entire process of gathering common forensic artefacts, combining them together and putting them in one place to be processed. Despite this being one of the most common asks from Incident Responders, no tool on the market is as seamless to use as this. 

#### What it does
1. Records all actions it does, so that when you inevitably need to figure out what has happened on the endpoint, you know which actions were you and which were the adversaries. 
2. Creates a remote staging location, innocuously named "PerformanceInformation"
3. Pushes winpmem across to the remote endpoint
4. *Checks if there is enough space on the endpoint to dump memory*
5. Dumps memory
* Extracts the following artefacts to your remote endpoint: 
    * Memory Dump to your endpoint (and confirms that the hash of what was dumped matches what actually ends up on your machine)
    b. All the event logs (i.e. the entire event log folder, not just the event logs that some random engineering team thinks are what you need)
    c. SRUM database (i.e. the forensic artifact which could allow you to a link a user, process and network activity together)
7. Processes each artefact using industry standard tools, dropping the output into a .json file for each one
    a. Memory Dump: Uses (https://github.com/volatilityfoundation/volatility3 "Volatility3") to do the following processing (more to come)
        i. PSList
        ii. PSScan
        iii. Cmdline
    b. SRU DB: Uses Mark Baggetts excellent (https://github.com/MarkBaggett/srum-dump "srum-dump") tool to process the SRUDB
8. Finishes up by going and deleting the Remote Staging location so that the endpoint doesn't get all clogged up by what you've done

Pretty awesome. And it's just the start. Using this platform, significant post-processing is also available :) 

## Next steps
1. Integrate the ability to zip using native windows tools
2. Integrate the ability to automatically upload to cloud storage (likely Amazon s3)
3. Integrate more forensic artifacts:
    a. Registry Hive 
    b. Prefetch
4. Start doing some basic post-processing analysis to make IR jobs even easier
