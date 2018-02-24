$env:HOME = $env:HOMEDRIVE + $env:HOMEPATH;

$env:WindowsPSProfileDir = $env:HOME + "\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1";
rm $env:WindowsPSProfilePath

$env:WindowsVimConfPath = $env:HOME + "\_vimrc";
rm $env:WindowsVimConfPath
