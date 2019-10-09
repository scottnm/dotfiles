$env:DotFilesPath = "$home\Dev\dotfiles";

# powershell profile paths
$env:PSProfilePath = "$env:DotFilesPath\config\ps_main.ps1";
$env:WindowsPSProfilePath = "$home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1";

# Vim paths
$env:WindowsVimConfPath = "$home\_vimrc";
$env:VimConfPath = "$env:DotFilesPath\config\_vimrc";
$env:WindowsVimAfterPath = "$home\vimfiles\after"
$env:WindowsVimSyntaxDir = "$env:WindowsVimAfterPath\syntax";

# Setup GHCI profile
$env:WindowsGhciConfPath = "$env:APPDATA\ghc\ghci.conf";
$env:GhciConfPath = "$env:DotFilesPath\config\.ghci";

# Install fonts
$env:FontsPath = "$env:DotFilesPath\fonts";
