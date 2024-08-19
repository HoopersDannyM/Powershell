# Parameters
param (
    [string]$remoteComputer = "VM NAME / PC NAME EG. LAPTOP12.DANNYS.LAN",
    [string]$scriptPath = "C:\Users\dannym\Documents\Powershell Scripts\EventLogReport.ps1"
)

# Enable Remoting on Local Machine
Enable-PSRemoting -Force

# Configure Trusted Hosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $remoteComputer -Force

# Get Credentials
$credential = Get-Credential

# Run Script on Remote Computer
Invoke-Command -ComputerName $remoteComputer -FilePath $scriptPath -Credential $credential