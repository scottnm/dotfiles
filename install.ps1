param(
    [switch]$All,
    [switch]$InstallDeps,
    [switch]$SkipInstallPrompt,
    [switch]$CloneDotFiles,
    [switch]$InstallPaths,
    [switch]$InstallFonts
    )

if (!$All -and !$InstallDeps -and !$CloneDotFiles -and !$InstallPaths)
{
    throw "Must specify one of the required switches"
}

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

if ($All -or $InstallDeps)
{
    # - chocolatey
    if (!(Get-Command choco -ErrorAction SilentlyContinue))
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    function ChocoInstallWithPrompt {
        param(
            [string]$package
        )
        if (!$SkipInstallPrompt) {
            $installYorN = Read-Host "Install $($package)? [y/n]"
            if ($installYorN.ToLower().Substring(0,1) -ne "y") {
                write-host -foregroundcolor yellow "Skipping '$package' install"
                return;
            }
        }
        choco install $package -y
    }

    ChocoInstallWithPrompt powershell-core
    ChocoInstallWithPrompt microsoft-windows-terminal
    ChocoInstallWithPrompt git
    ChocoInstallWithPrompt vim
    ChocoInstallWithPrompt powertoys
    ChocoInstallWithPrompt fzf
    ChocoInstallWithPrompt firefox
    ChocoInstallWithPrompt sharpkeys

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
}

if ($All -or $CloneDotFiles) {
    # clone dotfiles
    mkdir $HOME\dev
    cd $HOME\dev
    git clone https://github.com/scottnm/dotfiles
    cd dotfiles
} else {
    cd $HOME\dev\dotfiles
}

if ($All -or $InstallPaths) {
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
    # mkdir Split-Path $env:WindowsGhciConfPath -Parent
    # cmd /c mklink $env:WindowsGhciConfPath $env:GhciConfPath
}

if ($All -or $InstallFonts) {
    # Install fonts
    start $env:FontsPath\*.ttf
}

popd
