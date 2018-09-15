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
    if ($env:CurrentGitBranch)
    {
        $title = $title + $env:CurrentBranchTopic + " :: ";
    }
    $title = $title + "$(get-location)";
    [System.Console]::Title = $title;
}

function UpdateBranchTopic($currentBranch)
{
    $env:CurrentBranchTopic = $currentBranch.Split('/')[-1];
}

# on home machine
# function UpdateGitBranchVars
# {
#     $status = & git status $args 
# 
#     if (!$status)
#     {
#         $env:CurrentGitBranch = $null;
#     }
#     else
#     {
#         $env:CurrentGitBranch = $status.Split()[2]
#         $localend=$env:CurrentGitBranch.IndexOf('.')
#         if ($localend -ne -1)
#         {
#             $env:CurrentGitBranch = $env:CurrentGitBranch.Substring(0,$localend)
#         }
#         UpdateBranchTopic($env:CurrentGitBranch);
#     }
# }

function prompt
{
    Write-Host("")

    $status_string = " $(get-location) "

    UpdateGitBranchVars;

    if ($env:CurrentGitBranch)
    {
        $status_string += " :: "
        $status_string += $env:CurrentBranchTopic
    }
    $status_string += "
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

function howto-edit-git-exclude { echo "$GITROOT/.git/info/exclude" }

########
# MISC #
########
new-alias pd pushd -Force -Option AllScope
function grep($files, $pattern) { dir -recurse $files | select-string $pattern }
function grepc($pattern) { dir -recurse *.cpp,*.h,*sources*,*dirs* | select-string $pattern }
function gohosts { & pushd c:\windows\system32\drivers\etc }

# net stop beep
