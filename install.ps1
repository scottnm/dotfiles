$DotFilesPath = "$home\Dev\dotfiles";

$PSProfilePath = "$DotFilesPath\config\ps_main.ps1";
$WindowsPSProfileDir = "$home\Documents\WindowsPowerShell";
$WindowsPSProfilePath = "$WindowsPSProfileDir\Microsoft.PowerShell_profile.ps1";
cmd /c mklink $WindowsPSProfilePath $PSProfilePath

$WindowsVimConfPath = "$home\_vimrc";
$VimConfPath = "$DotFilesPath\config\_vimrc";
cmd /c mklink $WindowsVimConfPath $VimConfPath

$WindowsGhciConfPath1 = "$env:APPDATA\ghc\.ghci";
$WindowsGhciConfPath2 = "$env:APPDATA\ghc\ghci.conf";
$GhciConfPath = "$DotFilesPath\config\.ghci";
cmd /c mklink $WindowsGhciConfPath1 $GhciConfPath
cmd /c mklink $WindowsGhciConfPath2 $GhciConfPath

$afterPath = "$home\vimfiles\after"
mkdir $afterPath
$WindowsVimSyntaxDir = "$afterPath\syntax";
$syntaxes = "note","cpp";
foreach ($syn in $syntaxes)
{
    $WindowsVimSyntaxPath = "$WindowsVimSyntaxDir\$syn.vim";
    $VimSyntaxPath = "$DotFilesPath\config\$syn.vim";
    cmd /c mklink $WindowsVimSyntaxPath $VimSyntaxPath
}

git config --global core.editor "vim"
