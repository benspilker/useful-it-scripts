rem Cleanup desktop if too many loose files and notify via email

PowerShell.exe -ExecutionPolicy Bypass -Command "
    # Get username and build desktop paths
    \$User = New-Object System.Security.Principal.NTAccount((Get-WmiObject -Class Win32_ComputerSystem).UserName.Split('\')[1])
    \$var1 = (\$User | Select-Object -ExpandProperty Value)
    Set-Content -Path 'temp.txt' -Value \$var1
    \$desktoppath = 'C:\Users\' + (Get-Content temp.txt) + '\Desktop\'
    \$newpath = \$desktoppath + 'DesktopCleanup\'

    # Count total desktop items and icons
    \$totalitems = (Get-ChildItem \$desktoppath | Measure-Object).Count
    \$userIconNumber = (Get-ChildItem -Path \$desktoppath -Filter *.lnk | Measure-Object).Count
    \$publicIconNumber = (Get-ChildItem -Path \$desktoppath -Filter *.lnk | Measure-Object).Count
    \$totalicons = \$userIconNumber + \$publicIconNumber

    # Determine if cleanup is needed
    if ((\$totalitems - \$totalicons) -gt 25) {
        \$cleanThatShitUp = 'yes'
    }

    # Create cleanup folder if needed
    if (\$cleanThatShitUp -eq 'yes') {
        if (!(Test-Path -Path \$newpath)) {
            New-Item -ItemType Directory -Path \$newpath
        }

        # Move non-shortcut files to cleanup folder
        Get-ChildItem -Path \$desktoppath -Exclude *.lnk |
            Where-Object { \$_.Mode -like '*-a*' } |
            ForEach-Object { Move-Item -Path \$_.FullName -Destination \$newpath }
    }

    # Cleanup temp file
    Remove-Item 'temp.txt'

    # Email Configuration
    \$EmailTo = 'youremail@yourdomain.com'
    \$EmailFrom = 'filechecker@yourdomain.com'
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
    \$Body = \"There are too many loose files on the Desktop folder from \$name logged in as \$var1. The script put the contents into a folder called DesktopCleanup. There were a total of \$totalitems on the Desktop.\"
    \$Subject = 'Cleaned files on PC'

    # Send Email if cleanup was performed
    if (\$cleanThatShitUp) {
        Write-Output 'Cleaned that Shit up and sending email.'
        \$SMTPMessage = New-Object System.Net.Mail.MailMessage(\$EmailFrom, \$EmailTo, \$Subject, \$Body)
        \$SMTPClient.Send(\$SMTPMessage)
    }
"
