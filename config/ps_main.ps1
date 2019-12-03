$env:Desktop = "c:\users\scott\desktop"
$env:DevPath = $env:HOMEDRIVE + $env:HOMEPATH + "\dev";
$env:SideProfilePath = $env:DevPath + "\dotfiles\config\ps_side.ps1"
. $env:SideProfilePath

# DevEnv edit paths
function Edit-Profile { gvim $profile $env:SideProfilePath }
function Edit-Vimrc { gvim $HOME\_vimrc }
function Edit-GhciConf { gvim $env:APPDATA\ghc\ghci.conf }
function Edit-Hosts { gvim c:\windows\system32\drivers\etc\hosts }

function Get-Version { $PSVersionTable.PSVersion }

Import-Module PSReadLine

Set-PSReadLineOption -Colors @{
    Command            = 'Gray'
    Number             = 'Red'
    Member             = 'Yellow'
    Operator           = 'Magenta'
    Type               = 'Cyan'
    Variable           = 'Red'
    Parameter          = 'Green'
    ContinuationPrompt = 'White'
    Default            = 'White'
};

Set-PSReadlineKeyHandler -Key Tab -Function Complete

function UpdateWindowTitle
{
    $title = "";
    if ($env:GitBranch)
    {
        $title = $title + $env:GitTopic + " :: ";
    }
    $title = $title + "$(get-location)";
    [System.Console]::Title = $title;
}

function UpdateBranchTopic($currentBranch)
{
    $env:GitTopic = $currentBranch.Split('/')[-1];
}

function prompt
{
    Write-Host("")

    $status_string = " $(get-location) "

    UpdateGitBranchVars;

    if ($env:GitBranch)
    {
        $status_string += " :: "
        $status_string += $env:GitBranch
    }
    $status_string += " :: $(Get-Date)
 "

    UpdateWindowTitle;

    Write-Host ($status_string) -nonewline -foregroundcolor cyan
    return "> "
}

###############
# GIT ALIASES #
###############
function gc { & git commit -ev $args }
function ga { & git add --all $args }
function gp { & git push $args }
function gl { & git pull $args }
function gco { & git checkout $args; UpdateGitBranchVars; }
function gcol { & git checkout "@{-1}" $args; UpdateGitBranchVars; }
function gdl { & git branch -d $args; }
function gdll { & git branch -d "@{-1}" $args; }
function gdllf { & git branch -D "@{-1}" $args; }
function gue { & git checkout -- $args }
function gd { & git diff $args }
function gdc { & git diff --cached $args }
function gcp
{
    if ($args.Length -lt 1)
    {
        echo "Must supply at least one argument for the patch name"
    }
    else
    {
        $diffArgs = $args[0..($args.Length - 2)]
        $cmdString = "git diff $diffArgs > z:\patches\$($args[-1])"
        cmd /c $cmdString
        echo $cmdString
    }
}
function gti
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][string]$Path
    )

    & git update-index --assume-unchanged $Path
}
function gtui
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][string]$Path
    )

    & git update-index --no-assume-unchanged $Path
}
function gst { & git status $args }
function gstr { gst --no-renames --no-breaks }
function gbm { git branch -r | sls "origin/scmunro" }
<#
function gsql
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][int]$CommitCount
    )

    & "git rebase -i HEAD~${CommitCount}";
}
#>

function howto-edit-git-exclude { echo "$GITROOT/.git/info/exclude" }

########
# MISC #
########
new-alias pd pushd -Force -Option AllScope
function grep($files, $pattern) { dir -recurse $files | select-string $pattern }
function grepvs($pattern) { dir -recurse *.sln,*.props,*.vcx* | select-string $pattern }
function grepc($pattern)
{
    $grepResults = (dir -recurse *.cmd,*.ps1,*.rs,*.cpp,*.h,*sources*,*dirs*,*.sln,*.props,*.vcx* | select-string $pattern)
    if ($grepResults)
    {
        $grepPaths = $grepResults | %{$_.Path.ToString()}
        CopyPathListToClipboard $grepPaths
        $grepResults
    }
    else
    {
        echo "No results";
    }
}

function grepcc($pattern) { dir -recurse *.rs,*.cpp,*.h,*sources*,*dirs*,*.sln,*.props,*.vcx* | select-string $pattern -casesensitive }
function edit-hosts { vim c:\windows\system32\drivers\etc\hosts }

# net stop beep

function CopyClipboardWithGrepFiles
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][string[]]$files,
    [Parameter(Mandatory = $true)][string]$pattern
    )

    $grepResults = (grep $files $pattern)
    $grepPaths = $grepResults | select -property path
    CopyPathListToClipboard $grepResults
}

function CopyPathListToClipboard($pathList)
{
    $uniqueFileList = ($pathList | Get-Unique -AsString)
    echo $uniqueFileList
    set-clipboard ($uniqueFileList -join " ")
}

function setnetsh {netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"}
function clearnetsh {netsh winhttp reset proxy }

function RenameLowerCase($dir)
{
    $dir = $dir.TrimEnd("\");
    $tmpGuid = new-guid
    $tmpName = "$dir" + "_" + "$tmpGuid"
    mv $dir $tmpName

    $dir = $dir.ToLower();
    mv $tmpName $dir
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
