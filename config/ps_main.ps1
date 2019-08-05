$env:Desktop = "c:\users\scott\desktop"
$env:DevPath = $env:HOMEDRIVE + $env:HOMEPATH + "\dev";
$env:SideProfilePath = $env:DevPath + "\dotfiles\config\ps_side.ps1"
. $env:SideProfilePath

# DevEnv edit paths
function Edit-Profile { gvim $profile $env:SideProfilePath }
function Edit-Vimrc { gvim $HOME\_vimrc }
function Edit-Hosts { gvim c:\windows\system32\drivers\etc\hosts }

Import-Module PSReadLine
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
function grepc($pattern) { dir -recurse *.rs,*.cpp,*.h,*sources*,*dirs*,*.sln,*.props,*.vcx* | select-string $pattern }
function grepcc($pattern) { dir -recurse *.rs,*.cpp,*.h,*sources*,*dirs*,*.sln,*.props,*.vcx* | select-string $pattern -casesensitive }
function gohosts { & pushd c:\windows\system32\drivers\etc }

# net stop beep

function CopyClipboardWithGrepFiles
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][string[]]$files,
    [Parameter(Mandatory = $true)][string]$pattern
    )

    $uniqueFileList = ((grep $files $pattern) | %{$_.Path.ToString()} | Get-Unique -asstring)
    echo $uniqueFileList
    set-clipboard ($uniqueFileList -join " ")
}

function setnetsh {netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"}
function clearnetsh {netsh winhttp reset proxy }
