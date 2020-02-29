# New machine install

# TODO
# - remembear
# - remembear extension for firefox

# - chocolatey
if (!(Get-Command choco -ErrorAction SilentlyContinue))
{
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco install git
choco install vim
choco install firefox
choco install sharpkeys
choco install powertoys
choco install fzf

# - vimplug
md ~\vimfiles\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
  $uri,
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    "~\vimfiles\autoload\plug.vim"
  )
)

# clone dotfiles
mkdir ~\dev
pushd ~\dev
git clone https://github.com/scottnm/dotfiles
pushd dotfiles
.\install.ps1

popd
popd

$checkUserName = (git config user.name)
if (!$checkUserName)
{
    $username = Read-Host -Prompt "Git name? "
    git config --global user.name $username
}

$checkUserMail = (git config user.email)
if (!$checkUserMail)
{
    $mail = Read-Host -Prompt "Git email? "
    git config --global user.email $mail
}
