# ======================================
# Diskspace Checker, Editable Variables
# ======================================
$EmailTo       = "youremail@yourdomain.com"
$EmailFrom     = "diskspace@yourdomain.com"
$User          = "diskspace@yourdomain.com"
$CredFile      = "C:\download\emailcred.txt"
$SMTPServer    = "smtp.securence.com"

# Drive space thresholds (in percentage)
$DriveChecks = @(
    @{ Drive = "C:"; Threshold = 15 },
    @{ Drive = "E:"; Threshold = 15 },
    #@{ Drive = "F:"; Threshold = 15 } # Add additional drives here as needed
)

# ============================================
# Force TLS 1.2 for secure SMTP communication
# ============================================
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ==========================
# Load credentials
# ==========================
$SecurePassword = Get-Content $CredFile | ConvertTo-SecureString
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $SecurePassword

# =========================================
# Function to check space and email if low
# =========================================
function Check-DriveSpace {
    param (
        [string]$DriveLetter,
        [int]$FreeThresholdPercent
    )

    $ComputerName = $env:COMPUTERNAME
    $drive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$DriveLetter'" -ComputerName $ComputerName

    if (-not $drive) {
        Write-Warning "Drive $DriveLetter not found on $ComputerName."
        return
    }

    $freePercent = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 2)
    $availableGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    $totalGB     = [math]::Round($drive.Size / 1GB, 2)

    if ($freePercent -gt $FreeThresholdPercent) {
        Write-Host "Drive $DriveLetter: Available space is above threshold ($freePercent% free)."
    } else {
        Write-Host "Drive $DriveLetter: Space is low ($freePercent% free). Sending email alert..."

        $Body    = "Check disk space on drive $DriveLetter on $ComputerName.`nFree space: $freePercent% ($availableGB GB out of $totalGB GB). Threshold: $FreeThresholdPercent%."
        $Subject = "Disk Space on $ComputerName is Low - Drive $DriveLetter"

        $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
        $SMTPClient  = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
        $SMTPClient.EnableSsl = $true
        $SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Cred.UserName, $Cred.Password)
        $SMTPClient.Send($SMTPMessage)
    }
}

# ==========================
# Run checks for all drives
# ==========================
foreach ($driveCheck in $DriveChecks) {
    Check-DriveSpace -DriveLetter $driveCheck.Drive -FreeThresholdPercent $driveCheck.Threshold
}
