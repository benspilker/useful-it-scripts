rem Check local administrator users and send results via email

PowerShell.exe -ExecutionPolicy Bypass -Command "
    # System Info
    \$name = [System.Net.DNS]::GetHostName()

    # Get local administrator users
    \$adminusers = Get-CimInstance -ClassName Win32_Group -Filter 'SID = \"S-1-5-32-544\"' |
                   Get-CimAssociatedInstance -ResultClassName Win32_UserAccount

    # Email Configuration
    \$EmailTo = 'youremail@yourdomain.com'
    \$EmailFrom = 'userchecker@yourdomain.com'
    \$EmailUser = 'securence-authenticated-user@yourdomain.com'
    \$PW = 'securence-authenticated-user-password-here'
    \$SMTPServer = 'smtp.securence.com'
    \$SMTPClient = New-Object Net.Mail.SmtpClient(\$SMTPServer, 587)
    \$SMTPClient.EnableSsl = \$true
    \$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(\$EmailUser, \$PW)

    # Email Body and Subject
    \$Body = \"Local administrator users on \$name are: `n\$adminusers\"
    \$Subject = \"Local administrator users on \$name\"

    # Send Email
    Write-Output 'Sending Email.'
    \$SMTPMessage = New-Object System.Net.Mail.MailMessage(\$EmailFrom, \$EmailTo, \$Subject, \$Body)
    \$SMTPClient.Send(\$SMTPMessage)
"
