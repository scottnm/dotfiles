$env:Desktop = "c:\users\scmunro.REDMOND\Desktop"
$env:DevPath = $env:HOMEDRIVE + $env:HOMEPATH + "\Dev";
$env:SideProfilePath = $env:DevPath + "\dotfiles\config\ps_side.ps1"
. $env:SideProfilePath

Function Edit-Profile
{
    gvim $profile $env:SideProfilePath
}

Function Edit-Vimrc
{
    gvim $HOME\_vimrc
}

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
        $status_string += $env:GitTopic
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
function gcof { & git checkout "@{-1}" $args; UpdateGitBranchVars; }
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
function grepc($pattern) { dir -recurse *.cpp,*.h,*sources*,*dirs*,*.sln,*.props,*.vcx* | select-string $pattern }
function gohosts { & pushd c:\windows\system32\drivers\etc }

# net stop beep
