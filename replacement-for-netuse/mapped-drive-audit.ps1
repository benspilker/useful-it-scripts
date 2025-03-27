# This script is a replacement for net use
# In a scenario where you can't push a script as the end user but you can as SYSTEM, this script is for you.

# This allows you to push this script to a group of machines, run as system, and get the logged in user with their mapped drives as an email per PC

# Be sure to edit your smtp email details in the email details section


# Define the ComputerName and initialize an empty report
$ComputerName = hostname
$Report = @()

# Get the explorer process to retrieve owner SID
$explorer = Get-CimInstance -ComputerName $ComputerName -ClassName Win32_Process | Where-Object { $_.Name -eq 'explorer.exe' }
$sid = ($explorer.GetOwnerSid()).sid
$owner = $explorer.GetOwner()
$Person = "$($owner.Domain)\$($owner.User)"

# Access the registry provider
$RegProv = Get-WmiObject -List -Namespace 'root\default' -ComputerName $ComputerName | Where-Object { $_.Name -eq 'StdRegProv' }

# Enumerate the drives under the user's Network share registry key
$Hive = [long]2147483651
$DriveList = $RegProv.EnumKey($Hive, "$sid\Network")

# Build the report with drive and remote path details
foreach ($drive in $DriveList.sNames) {
    $remotePath = ($RegProv.GetStringValue($Hive, "$sid\Network\$drive", "RemotePath")).sValue
    $Report += [PSCustomObject]@{
        ComputerName = $ComputerName
        User         = $Person
        Drive        = $drive
        Share        = $remotePath
    }
}

# Get the host name of the device
$name = [System.Net.DNS]::GetHostName()

# Create the email body and subject
$reportString = $Report | Out-String
$Body = "Script on device $name retrieved this mapped drive information: $reportString"

# Email details
$EmailTo = '<youremail@yourdomain.com>'
$EmailFrom = 'mapped-drive-audit@yourdomain.com'
$EmailUser = '<securence-authenticated-user@yourdomain.com>'
$PW = 'securence-authenticated-user-password-here>'
$Subject = "Mapped Drive Audit Script Deployed on $name"
$SMTPServer = 'smtp.securence.com'

# Set up and send the email
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailUser, $PW)
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $Subject, $Body)
$SMTPClient.Send($SMTPMessage)

Write-Output "Email sent successfully with mapped drive information."