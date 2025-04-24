:while1
timeout 10
netsh interface set interface name="Ethernet" admin=disabled
timeout 10
netsh interface set interface name="Ethernet" admin=enabled
goto :while1