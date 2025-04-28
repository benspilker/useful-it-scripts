# Email Configuration
$EmailTo   = 'youremail@yourdomain.com'  
$EmailFrom = 'mapped-drive-audit@yourdomain.com'
$EmailUser = 'securence-authenticated-user@yourdomain.com'  
$PW        = 'securence-authenticated-user-password-here'
$SMTPServer = 'smtp.securence.com'

$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($EmailUser, $PW)

# Host file and system info
$name = [System.Net.DNS]::GetHostName()
$hostfile = Get-Content 'C:\Windows\System32\drivers\etc\hosts'
$measureObject = $hostfile | Measure-Object -Character
$count = $measureObject.Characters

# Email body content
$Body = @"
Host file on $name likely modified.
"@

$BodySafe = @"
Host file on $name is exactly 782 characters and is likely NOT modified.
"@

$NewBody = @"
$Body

$hostfile
"@

# Subject lines for email
$SubjectSafe   = 'Host File Clean'
$SubjectUnSafe = 'Host File Likely Modified'

# Send email based on host file character count
if ($count -eq 782) {
    Write-Output 'Host file is exactly 782 characters and is likely NOT modified, sending an email.'
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $SubjectSafe, $BodySafe)
    $SMTPClient.Send($SMTPMessage)
} else {
    Write-Output 'Host file is likely modified, sending an email.'
    $SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom, $EmailTo, $SubjectUnSafe, $NewBody)
    $SMTPClient.Send($SMTPMessage)
}
