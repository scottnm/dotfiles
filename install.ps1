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
    # Install chocolatey; not needed for 
    if (!(Get-Command choco -ErrorAction SilentlyContinue))
    {
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }

    function Install-WithWinget
    {
        param([string]$Pkg)

        Write-Host -ForegroundColor Cyan "Installing $Pkg via WinGet"
        $extraWinGetInstallArgs = @()
        if ($SkipInstallPrompt)
        {
            $extraWinGetInstallArgs = @("--disable-interactivity", "--silent", "--accept-source-agreements", "--accept-package-agreements")
        }
        winget install $Pkg @extraWinGetInstallArgs
    }


    Install-WithWinget git.git 
    Install-WithWinget pwsh 
    Install-WithWinget vim.vim 
    Install-WithWinget neovim.neovim 
    Install-WithWinget Microsoft.VisualStudioCode 
    Install-WithWinget Microsoft.VisualStudio.2022.Enterprise
    Install-WithWinget junegunn.fzf 
    Install-WithWinget RandyRants.SharpKeys 

    # setup git after initial installation
    & .\gitsetup.ps1

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

if ($All -or $CloneDotFiles -or $InstallPaths) {
    # ensure setup git prior to cloning our dotfiles or doing anything which involves git
    & .\gitsetup.ps1
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
    & .\paths.ps1

    # Setup powershell profile
    & .\SetupPwshProfiles.ps1

    function IsSymLink {
        param([string]$path)
        $file = Get-Item $path -Force -ea SilentlyContinue
        return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
    }

    function CreateSymLink {
        param([string]$Target, [string]$Src)
        if (Test-Path $Target)
        {
            if (IsSymLink $Target)
            {
                write-host -foregroundcolor darkgray "Deleting old symlink: $Target"
            }
            else
            {
                write-host -foregroundcolor yellow "Not creating symlink $Target <==> $Src! Target is non-symlink file"
                return
            }

            rm -rec -for $Target | Out-Null
        }
        cmd /c mklink $Target $Src
    }

    # Setup Windows Terminal profile
    # CreateSymLink -Target $env:LocalWinTermPath -Src $env:WinTermPath

    # Setup Vim profile
    CreateSymLink -Target $env:WindowsVimConfPath -Src $env:VimConfPath
    CreateSymLink -Target $env:WindowsVimGConfPath -Src $env:VimGConfPath
    CreateSymLink -Target $env:WindowsNVimConfPath -Src $env:NVimConfPath
    CreateSymLink -Target $env:WindowsNVimGConfPath -Src $env:NVimGConfPath
    mkdir -Force $env:WindowsVimAfterPath
    mkdir -Force $env:WindowsVimSyntaxDir
    $syntaxes = @("note", "cpp");
    foreach ($syntax in $syntaxes)
    {
        $WindowsVimSyntaxPath = "$env:WindowsVimSyntaxDir\$syntax.vim";
        $VimSyntaxPath = "$env:DotFilesPath\config\$syntax.vim";
        echo $WindowsVimSyntaxPath
        echo $VimSyntaxPath
        CreateSymLink -Target $WindowsVimSyntaxPath -Src $VimSyntaxPath
    }

    # Setup GHCI profile
    # mkdir Split-Path $env:WindowsGhciConfPath -Parent
    # CreateSymLink -Target $env:WindowsGhciConfPath -Src $env:GhciConfPath
}

if ($All -or $InstallFonts) {
    # Install fonts
    start $env:FontsPath\*.ttf
}

popd
