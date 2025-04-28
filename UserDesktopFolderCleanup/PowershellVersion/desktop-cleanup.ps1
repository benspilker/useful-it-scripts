# Get username and build desktop paths
$User = New-Object System.Security.Principal.NTAccount((Get-WmiObject -Class Win32_ComputerSystem).UserName.Split('\')[1])
$var1 = ($User | Select-Object -ExpandProperty Value)
$desktoppath = "C:\Users\$var1\Desktop\"
$newpath = Join-Path $desktoppath "DesktopCleanup"

# Count total desktop items and icons
$totalitems = (Get-ChildItem -Path $desktoppath | Measure-Object).Count
$userIconNumber = (Get-ChildItem -Path $desktoppath -Filter *.lnk | Measure-Object).Count
$publicIconNumber = (Get-ChildItem -Path $desktoppath -Filter *.lnk | Measure-Object).Count
$totalicons = $userIconNumber + $publicIconNumber

# Determine if cleanup is needed
if (($totalitems - $totalicons) -gt 25) {
    $cleanThatShitUp = 'yes'
}

# Create cleanup folder and move files
if ($cleanThatShitUp -eq 'yes') {
    if (!(Test-Path -Path $newpath)) {
        New-Item -ItemType Directory -Path $newpath | Out-Null
    }

    # Move non-shortcut files to cleanup folder
    Get-ChildItem -Path $desktoppath -File -Exclude *.lnk |
        ForEach-Object { Move-Item -Path $_.FullName -Destination $newpath }
}

# Email Configuration
$EmailTo = 'youremail@yourdomain.com'
$EmailFrom = 'filechecker@yourdomain.com'
$EmailUser = 'securence-authenticated-user@yourdomain.com'
$PW = 'securence-authenticated-user-password-here'
$SMTPServer = 'smtp.securence.com'
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailUser, $PW)

# System Info
$name = [System.Net.DNS]::GetHostName()
$ip = (Invoke-WebRequest -Uri "http://ifconfig.me/ip" -UseBasicParsing).Content.Trim()

# Email Body and Subject
$Body = "There are too many loose files on the Desktop folder from $name logged in as $var1. The script put the contents into a folder called DesktopCleanup. There were a total of $totalitems on the Desktop."
$Subject = "Cleaned files on PC"

# Send Email if cleanup was performed
if ($cleanThatShitUp) {
    Write-Output "Cleaned that Shit up and sending email."
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
    $SMTPClient.Send($SMTPMessage)
} else {
    Write-Output "No cleanup needed. No email sent."
}
