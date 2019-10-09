& $PSScriptRoot\paths.ps1

# Setup powershell profile
cmd /c mklink $env:WindowsPSProfilePath $env:PSProfilePath

# Setup Vim profile
cmd /c mklink $env:WindowsVimConfPath $env:VimConfPath
mkdir -Force $env:WindowsVimAfterPath
mkdir -Force $env:WindowsVimSyntaxDir
$syntaxes = @("note", "cpp");
foreach ($syntax in $syntaxes)
{
    $WindowsVimSyntaxPath = "$env:WindowsVimSyntaxDir\$syntax.vim";
    $VimSyntaxPath = "$env:DotFilesPath\config\$syntax.vim";
    echo $WindowsVimSyntaxPath
    echo $VimSyntaxPath
    cmd /c mklink $WindowsVimSyntaxPath $VimSyntaxPath
}

# Setup GHCI profile
cmd /c mklink $env:WindowsGhciConfPath $env:GhciConfPath

# Install fonts
start $env:FontsPath\*.ttf

# Setup git config
git config --global core.editor "C:/Windows/gvim.bat"

# Setup chocolatey and chocolatey installs
if (!(Get-Command choco -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install powertoys
}
