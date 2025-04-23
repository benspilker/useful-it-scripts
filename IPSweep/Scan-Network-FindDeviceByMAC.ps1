# === CONFIGURABLE VARIABLES ===

# Change your subnet to match your network
# Change Target MAC to find the device you're looking for (or leave the default if you don't have a target)

$TargetMAC = "0C:38:3E:5D:C5:D2"  # Can be with dashes, colons, or just digits

$Subnet = "10.1.10" # Only type 3 octets
$Start = 1
$End = 254
$PingCount = 1



# === Normalize Target MAC ===
$NormalizedTargetMAC = ($TargetMAC -replace '[-:]', '').ToUpper()

# === MAIN LOOP ===
for ($i = $Start; $i -le $End; $i++) {
    $IP = "$Subnet.$i"
    try {
        $PingResult = Test-Connection -ComputerName $IP -Count $PingCount -ErrorAction Stop

        if ($PingResult) {
            $PingTime = ($PingResult | Measure-Object ResponseTime -Average).Average
            $null = ping -n 1 $IP | Out-Null

            # === Get Hostname ===
            try {
                $Hostname = ([System.Net.Dns]::GetHostEntry($IP)).HostName
            } catch {
                $Hostname = "Unknown"
            }

            $mac = $null
            $NormalizedMAC = $null

            arp -a | ForEach-Object {
                $line = $_.Trim()
                if ($line -like "$IP*") {
                    $fields = $line -split "\s+"
                    if ($fields.Length -ge 3) {
                        $mac = $fields[1].ToUpper()
                        $NormalizedMAC = ($mac -replace '[-:]', '')
                    }
                }
            }

            if ($mac) {
                Write-Host "$IP - True - MAC: $mac - Hostname: $Hostname - Ping: ${PingTime}ms"
                if ($NormalizedMAC -eq $NormalizedTargetMAC) {
                    Write-Host "  Found target device at IP $IP with MAC $mac"
                    $response = Read-Host "  Target found. Do you want to continue scanning? (Y/N)"
                    if ($response -notmatch '^(Y|y)') {
                        break
                    }
                }
            } else {
                Write-Host "$IP - True - MAC: Unknown - Hostname: $Hostname - Ping: ${PingTime}ms"
            }
        }
    } catch {
        # No output for unreachable hosts
    }
}