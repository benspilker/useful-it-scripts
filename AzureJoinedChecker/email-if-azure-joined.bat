rem Check if PC is Azure AD joined, and send an email if not

PowerShell.exe -ExecutionPolicy Bypass -Command "
    # System Info
    \$name = [System.Net.DNS]::GetHostName()
    \$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    \$joinedstring = (dsregcmd /status | Select-Object -Last 10 | Select-Object -First 1)
    \$joinedstring = \$joinedstring -replace ' '

    # Email Configuration
    \$EmailTo = 'youremail@yourdomain.com'
    \$EmailFrom = 'domainnamechecker@ne-inc.com'
    \$EmailUser = 'securence-authenticated-user@yourdomain.com'
    \$PW = 'securence-authenticated-user-password-here'
    \$SMTPServer = 'smtp.securence.com'
    \$SMTPClient = New-Object Net.Mail.SmtpClient(\$SMTPServer, 587)
    \$SMTPClient.EnableSsl = \$true
    \$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(\$EmailUser, \$PW)

    # Email Body and Subject
    \$Body = \"Script Found PC \$name with user \$username not AzureAd joined\"
    \$Subject = 'PC needs Azure Joined'

    # Send Email if device is not Azure AD joined
    if (\$joinedstring -eq 'IsDeviceJoined:NO') {
        Write-Output 'PC not AzureJoined. Sending Email.'
        \$SMTPMessage = New-Object System.Net.Mail.MailMessage(\$EmailFrom, \$EmailTo, \$Subject, \$Body)
        \$SMTPClient.Send(\$SMTPMessage)
    }
"
