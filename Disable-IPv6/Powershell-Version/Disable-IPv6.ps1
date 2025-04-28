# Disable IPv6 on Ethernet
Disable-NetAdapterBinding -InterfaceAlias 'Ethernet' -ComponentID 'ms_tcpip6'

# Disable IPv6 on Wi-Fi
Disable-NetAdapterBinding -InterfaceAlias 'Wi-Fi' -ComponentID 'ms_tcpip6'

Write-Output "IPv6 has been disabled on Ethernet and Wi-Fi adapters."
