rem Disable IPv6 on Ethernet and Wi-Fi, then email external IP of the PC

PowerShell.exe -ExecutionPolicy Bypass -Command "
    # Disable IPv6 on Ethernet and Wi-Fi
    Disable-NetAdapterBinding -InterfaceAlias 'Ethernet' -ComponentID ms_tcpip6
    Disable-NetAdapterBinding -InterfaceAlias 'Wi-Fi' -ComponentID ms_tcpip6

    # Email Configuration
    \$EmailTo = 'youremail@yourdomain.com'
    \$EmailFrom = 'hostfilechecker@yourdomain.com'
    \$EmailUser = 'securence-authenticated-user@yourdomain.com'
    \$PW = 'securence-authenticated-user-password-here'
    \$SMTPServer = 'smtp.securence.com'
    \$SMTPClient = New-Object Net.Mail.SmtpClient(\$SMTPServer, 587)
    \$SMTPClient.EnableSsl = \$true
    \$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(\$EmailUser, \$PW)

    # System Info
    \$name = [System.Net.DNS]::GetHostName()
    \$ip = (Invoke-WebRequest ifconfig.me/ip -UseBasicParsing).Content.Trim()

    # Email Body and Subject
    \$Body = \"External IP from \$name is \$ip\"
    \$Subject = 'External IP for PC'

    # Send Email if IP was successfully retrieved
    if (\$ip) {
        Write-Output 'Got External IP, sending email.'
        \$SMTPMessage = New-Object System.Net.Mail.MailMessage(\$EmailFrom, \$EmailTo, \$Subject, \$Body)
        \$SMTPClient.Send(\$SMTPMessage)
    }
"
