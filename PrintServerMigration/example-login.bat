rem example login script

net use t: /delete /y
net use t: \\data2012\SharedData

rem append this line below to your login script
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '\\DATA2019\sysvol\yourdomain.local\scripts\printers.ps1'"