$env:DotFilesPath = "$home\Dev\dotfiles";

# powershell profile paths
$env:PSProfilePath = "$env:DotFilesPath\config\ps_main.ps1";
$env:PSSideProfilePath = "$env:OneDrive\projects\dev\private_dotfiles\ps_side.ps1";
$env:WindowsPSPath = "$home\Documents\WindowsPowerShell\";
$env:WindowsPSCorePath = "$home\Documents\PowerShell\";
$env:WindowsPSProfilePath = "$home\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1";
$env:WindowsPSCoreProfilePath = "$home\Documents\PowerShell\Microsoft.PowerShell_profile.ps1";
$env:WindowsPSSideProfilePath = "$env:DotFilesPath\config\ps_side.ps1"

# Windows Terminal paths
$env:WinTermPath = "$env:DotFilesPath\config\winterm_profiles.json"
$env:LocalWinTermPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

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
