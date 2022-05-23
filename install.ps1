#
# New machine install
#

# First warn if not running as admin
$isAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
if (!$isAdmin)
{
    Write-Warning "It is recommended to run as admin!"
    Read-Host "Ctrl-c to quit. Enter to continue"
}

pushd .

# - chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# - remembear
$remembearUrl = "https://s3.amazonaws.com/remembear/app/release/downloads/windows/RememBear_x64.exe"
iwr -uri $remembearUrl -OutFile "~\Downloads\rx64.exe"
. ~\Downloads\rx64.exe

choco install powershell-core -y
choco install microsoft-windows-terminal -y
choco install git -y
choco install vim -y
choco install powertoys -y
choco install fzf -y
# choco install firefox -y
# choco install sharpkeys -y

# refresh after installing everything
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
	";" +
	[System.Environment]::GetEnvironmentVariable("Path","User")

# - vimplug
md $HOME\vimfiles\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
  $uri,
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    "$HOME\vimfiles\autoload\plug.vim"
  )
)

# clone dotfiles
mkdir $HOME\dev
cd $HOME\dev
git clone https://github.com/scottnm/dotfiles
cd dotfiles

& .\gitsetup.ps1
& .\paths.ps1

# Setup powershell profile
& .\SetupPwshProfiles.ps1

# Setup Windows Terminal profile
rm $env:LocalWinTermPath
cmd /c mklink $env:LocalWinTermPath $env:WinTermPath

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
mkdir Split-Path $env:WindowsGhciConfPath -Parent
cmd /c mklink $env:WindowsGhciConfPath $env:GhciConfPath

# Install fonts
start $env:FontsPath\*.ttf

popd
