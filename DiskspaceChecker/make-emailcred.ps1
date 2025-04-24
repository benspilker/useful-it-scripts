# This creates an encrypted version of your smtp user password 
# The password uses the Windows cyptography and is unique to the user profile that generates the script
# This means the scheduled task must run as the same user that this is generated as

$passstring=("<your-smtp-auth-password-here>" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString)
$path = "C:\download\"
If(!(test-path $path)){New-Item -ItemType Directory -Force -Path $path}
echo $passstring >C:\download\emailcred.txt