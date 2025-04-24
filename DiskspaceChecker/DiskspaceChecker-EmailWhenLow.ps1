# ======================================
# Diskspace Checker, Editable Variables
# ======================================
$EmailTo       = "youremail@yourdomain.com"
$EmailFrom     = "diskspace@yourdomain.com"
$User          = "diskspace@yourdomain.com"
$CredFile      = "C:\download\emailcred.txt"
$SMTPServer    = "smtp.securence.com"

# Drive space thresholds (in GB)
$DriveChecks = @(
    @{ Drive = "C:"; Threshold = 10 },
    @{ Drive = "E:"; Threshold = 50 },
    #@{ Drive = "F:"; Threshold = 100 } # Add additional drives here as needed
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
        [int]$FreeThresholdGB
    )

    $ComputerName = $env:COMPUTERNAME
    $drive = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$DriveLetter'" -ComputerName $ComputerName

    if (-not $drive) {
        Write-Warning "Drive $DriveLetter not found on $ComputerName."
        return
    }

    $availableGB = [math]::Round($drive.FreeSpace / 1GB)
    $totalGB     = [math]::Round($drive.Size / 1GB)

    if ($availableGB -gt $FreeThresholdGB) {
        Write-Host "Drive $DriveLetter: Available space is above threshold ($availableGB GB)."
    } else {
        Write-Host "Drive $DriveLetter: Space is low ($availableGB GB). Sending email alert..."

        $Body    = "Check disk space on drive $DriveLetter on $ComputerName. Below threshold of $FreeThresholdGB GB.`nAvailable: $availableGB GB out of $totalGB GB."
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
    Check-DriveSpace -DriveLetter $driveCheck.Drive -FreeThresholdGB $driveCheck.Threshold
}
