# Get ARP table entries
$arpEntries = arp -a

# Process each line of ARP output
$arpEntries -match 'dynamic' | ForEach-Object {
    # Extract IP address
    if ($_ -match "\d+\.\d+\.\d+\.\d+") {
        $ip = $matches[0]

        # Try to resolve Hostname
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($ip)
            $hostName = $hostEntry.HostName
        }
        catch {
            $hostName = "Name not found"
        }

        # Output IP and Hostname
        Write-Output "IP: $ip, Name: $hostName"
    }
}

