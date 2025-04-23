rem Script to create local admin user

rem modify the password. Note: Password cannot contain username

PowerShell.exe -ExecutionPolicy Bypass -Command "$Password = ('<LocalAdminPassword>' | ConvertTo-SecureString -AsPlainText -Force);New-LocalUser 'LocalAdmin' -Password $Password -FullName 'Local Admin';Set-LocalUser -Name 'LocalAdmin' -PasswordNeverExpires 1;Add-LocalGroupMember -Group 'Administrators' -Member 'LocalAdmin'"