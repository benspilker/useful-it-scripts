#deletes any network printer on a workstation where oldserver is in the printer name, then adds printers of the same sharename to a newserver

$oldserver="data2012"

$newserver="data2019"


$printerarray = @()
$printerarray=@(get-printer | where name -like *$oldserver*)
$printercount=$printerarray.count
if ($printerarray){
$defaultprinter = gwmi win32_printer -computername localhost | where {$_.Default -eq $true}
if ($defaultprinter.Name -like "*$oldserver*"){
$default=($defaultprinter.Name -replace [Regex]::Escape('\') -replace $oldserver)
$newdefault="\\$newserver\$default"
}
}

while ($printercount -gt 0){

$printername=(get-printer | where name -like *$oldserver* | select -last 1 | select name)
$printername= $printername -replace 'name' -replace '@{=' -replace '}'
if ($printername){
Remove-Printer -Name $printername

$printercount=($printercount-1)

echo "removing $printername"

$sharename=($printername -replace [Regex]::Escape('\') -replace $oldserver)

$newprintername="\\$newserver\$sharename"

Add-Printer -ConnectionName $newprintername
echo "adding $newprintername"
}

$printerarray = @()
$printerarray=@(get-printer | where name -like *$oldservername*)

}

if ($default){(New-Object -ComObject WScript.Network).SetDefaultPrinter("$newdefault")}