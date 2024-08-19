# Get all network adapters
$allAdapters = Get-NetAdapter

# Filter for WiFi adapters
$wifiAdapters = $allAdapters | Where-Object {$_.Name -like "*Wi-Fi*" -or $_.Name -like "*Wireless*" -or $_.InterfaceDescription -like "*Wireless*" -or $_.InterfaceDescription -like "*Wi-Fi*" }

# Check and disable RSC on all found WiFi adapters
foreach ($adapter in $wifiAdapters) {
    $rscStatus = Get-NetAdapterRsc -Name $adapter.Name
    if ($rscStatus.Enabled) {
        Disable-NetAdapterRsc -Name $adapter.Name
        Write-Host "RSC was enabled on WiFi adapter:" $adapter.Name ", disabling it now."
    } else {
        Write-Host "RSC is already disabled on WiFi adapter:" $adapter.Name
    }
}

# Check and disable IPv6 on all network adapters
foreach ($adapter in $allAdapters) {
    $ipv6Status = Get-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
    if ($ipv6Status.Enabled) {
        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
        Write-Host "IPv6 was enabled on adapter:" $adapter.Name ", disabling it now."
    } else {
        Write-Host "IPv6 is already disabled on adapter:" $adapter.Name
    }
}
