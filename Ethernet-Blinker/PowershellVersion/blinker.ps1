while ($true) {
    Start-Sleep -Seconds 10
    netsh interface set interface name="Ethernet" admin=disabled
    Start-Sleep -Seconds 10
    netsh interface set interface name="Ethernet" admin=enabled
}
