$env:HOME = $env:HOMEDRIVE + $env:HOMEPATH;

$env:DotFilesPath = $env:HOME + "\Dev\dotfiles";

$env:PSProfilePath = $env:DotFilesPath + "\config\ps_main.ps1";
$env:WindowsPSProfileDir = $env:HOME + "\Documents\WindowsPowerShell";
$env:WindowsPSProfilePath = $env:WindowsPSProfileDir + "\Microsoft.PowerShell_profile.ps1";

echo "Ensuring PS folder exists...";
mkdir $env:WindowsPSProfileDir;
echo "Creating symlink for PS profile for $env:PSProfilePath $env:WindowsPSProfilePath";
cmd /c mklink $env:WindowsPSProfilePath $env:PSProfilePath
cmd /c echo "$env:WindowsPSProfilePath $env:PSProfilePath"

#$env:WindowsVimConfPath = $env:HOME + "\_vimrc";
#$env:VimConfPath = $env:DotFilesPath + "\config\_vimrc";
#cmd /c mklink $env:WindowsVimConfPath $env:VimConfPath

#git config --global core.editor "vim"
