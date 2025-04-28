# Set the local admin password (replace with a secure value)
$PlainPassword = '<LocalAdminPassword>'  # Replace this with your actual password
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force

# Create the LocalAdmin user
New-LocalUser -Name 'LocalAdmin' -Password $SecurePassword -FullName 'Local Admin' -PasswordNeverExpires

# Set password to never expire (if not already set above)
Set-LocalUser -Name 'LocalAdmin' -PasswordNeverExpires $true

# Add the user to the Administrators group
Add-LocalGroupMember -Group 'Administrators' -Member 'LocalAdmin'

Write-Output "LocalAdmin user created and added to Administrators group."
