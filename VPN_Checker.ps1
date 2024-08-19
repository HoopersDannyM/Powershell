# Define the output folder and file
$outputFolder = "$env:USERPROFILE\Documents\powershell outputs\vpn checker"
$outputFile = "$outputFolder\vpn_check_results.txt"

# Create the folder structure if it doesn't exist
if (-not (Test-Path -Path $outputFolder)) {
    New-Item -ItemType Directory -Force -Path $outputFolder
}

# Define the VPN server address
$vpnServer = "dc1.hoopers.org.uk"

# Initialize an array to collect the output
$output = @()

# Ping test
$output += "Ping Test:"
$output += "=========="
$pingResult = Test-Connection -ComputerName $vpnServer -Count 4
$output += $pingResult | Format-Table -AutoSize | Out-String

# Traceroute
$output += "`nTraceroute:"
$output += "==========="
$tracertResult = tracert $vpnServer
$output += $tracertResult

# Firewall Configuration Check
$output += "`nFirewall Configuration Check:"
$output += "============================="
# Check if the firewall allows UDP port 500
$firewallUDP = Get-NetFirewallRule -Protocol UDP -RemotePort 500
$output += $firewallUDP | Format-Table -AutoSize | Out-String
# Check if the firewall allows IPsec (ESP)
$firewallESP = Get-NetFirewallRule -Protocol ESP
$output += $firewallESP | Format-Table -AutoSize | Out-String

# DNS Configuration Check
$output += "`nDNS Configuration Check:"
$output += "========================="
$dnsResult = nslookup $vpnServer
$output += $dnsResult

# Write the output to the file
$output | Out-File -FilePath $outputFile

# Notify the user
Write-Host "VPN check results saved to $outputFile"
