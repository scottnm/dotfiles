$env:HOME = $env:HOMEDRIVE + $env:HOMEPATH;

$env:DotFilesPath = $env:HOME + "\Dev\dotfiles";

$env:PSProfilePath = $env:DotFilesPath + "\config\ps_main.ps1";
$env:WindowsPSProfileDir = $env:HOME + "\Documents\WindowsPowerShell";
$env:WindowsPSProfilePath = $env:WindowsPSProfileDir + "\Microsoft.PowerShell_profile.ps1";
cmd /c mklink $env:WindowsPSProfilePath $env:PSProfilePath

$env:WindowsVimConfPath = $env:HOME + "\_vimrc";
$env:VimConfPath = $env:DotFilesPath + "\config\_vimrc";
cmd /c mklink $env:WindowsVimConfPath $env:VimConfPath

$env:WindowsGhciConfPath = $env:HOME + "\.ghci";
$env:GhciConfPath = $env:DotFilesPath + "\config\.ghci";
cmd /c mklink $env:WindowsGhciConfPath $env:GhciConfPath

$env:WindowsVimSyntaxDir = $env:HOME + "\vimfiles\after\syntax";

$syntaxes = "note","cpp";
foreach ($syn in $syntaxes)
{
    $env:WindowsVimSyntaxPath = $env:WindowsVimSyntaxDir + "\" + $syn + ".vim";
    $env:VimSyntaxPath = $env:DotFilesPath + "\config\" + $syn + ".vim";
    cmd /c mklink $env:WindowsVimSyntaxPath $env:VimSyntaxPath
}

git config --global core.editor "vim"
