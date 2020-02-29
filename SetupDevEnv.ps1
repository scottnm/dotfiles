# TODO
# New machine install:
#
# - remembear
# - remembear extension for firefox

# - chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# - git
choco install git

# - gvim
choco install vim

# - firefox
choco install firefox

# - sharpkeys
choco install sharpkeys

# - vimplug
md ~\vimfiles\autoload
$uri = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
(New-Object Net.WebClient).DownloadFile(
  $uri,
  $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    "~\vimfiles\autoload\plug.vim"
  )
)

mkdir ~\dev
pushd ~\dev
git clone https://github.com/scottnm/dotfiles
pushd dotfiles
.\install.ps1

popd
popd
