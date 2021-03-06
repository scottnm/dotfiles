$env:SideProfilePath = "$HOME\dev\dotfiles\config\ps_side.ps1"

function Ensure-Module
{
    Param(
        [string]$Name
        )

    try {
        Import-Module $Name -ErrorAction stop
    }
    catch {
        Write-Warning "Couldn't import module $Name. Attempting install..."
        Install-Module -Name $Name
        Import-Module $Name
    }
}

. $env:SideProfilePath

# vim aliases
# new-alias cvim c:\windows\vim.bat -Force -Option AllScope
# new-alias vim c:\windows\gvim.bat -Force -Option AllScope
new-alias vim gvim -Force -Option AllScope

# DevEnv edit paths
function Edit-Profile { gvim $profile $env:SideProfilePath }
function Edit-Vimrc { gvim $HOME\_vimrc }
function Edit-GhciConf { gvim $env:APPDATA\ghc\ghci.conf }
function Edit-Hosts { gvim c:\windows\system32\drivers\etc\hosts }
function Edit-GitConfig {
    Param([switch]$Global) $globalFlag = if ($Global) { "--global" } else { "" }
    git config $globalFlag -e
}
function Edit-TopicNotes {
    $path = Join-Path -path $env:TopicNotesDir -ChildPath "${env:GitTopic}_notes.md"
    gvim $path
}
function Get-Version { $PSVersionTable.PSVersion }

Import-Module PSReadLine
Ensure-Module -Name Posh-Git

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

function Colored
{
    Param(
        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter(Mandatory)]
        [ValidateSet("Gray", "Red", "Green", "Yellow", "Blue", "Pink", "Cyan")]
        [string]$Color
        )

    $code = 0
    if ($Color -eq "Gray")
    {
        $code = 30
    }
    elseif ($Color -eq "Red")
    {
        $code = 31
    }
    elseif ($Color -eq "Green")
    {
        $code = 32
    }
    elseif ($Color -eq "Yellow")
    {
        $code = 33
    }
    elseif ($Color -eq "Blue")
    {
        $code = 34
    }
    elseif ($Color -eq "Pink")
    {
        $code = 35
    }
    elseif ($Color -eq "Cyan")
    {
        $code = 36
    }

    return "`e[$($code)m$($Text)`e[0m"
}

function prompt
{
    RefreshCwdSensitiveState;
    Write-Host("")

    $locationPrompt = Colored -Text (Get-Location).Path -Color Cyan
    $statusLine = " $locationPrompt"

    UpdateGitBranchVars;

    if ($env:GitBranch)
    {
        $branchPrompt = Colored -Text $env:GitBranch -Color Green
        $statusLine += " :: $branchPrompt"
    }
    $statusLine += " :: $(Get-Date)
 "

    UpdateWindowTitle;

    Write-Host $statusLine -nonewline
    $prompt = "λ"
    return "$(Colored -Text $prompt -Color Yellow) "
}

###############
# GIT ALIASES #
###############
function gsu
{
    Param(
        [string]$Remote
        )

    UpdateGitBranchVars
    if (!$Remote)
    {
        $Remote = $env:GitBranch
    }

    if ($env:GitBranch)
    {
        git branch --set-upstream-to=origin/$Remote $env:GitBranch
    }
}

function GitRenameTag
{
    [CmdletBinding( )]
    Param(
        [string]$Remote = "origin",

        [Parameter(Mandatory = $true)]
        [string]$Old,

        [Parameter(Mandatory = $true)]
        [string]$New,

        [switch]$Apply
        )

    $cmd = "git push -f $Remote $($Old):refs/tags/$New :$Old"

    if ($Apply)
    {
        Write-Host -ForegroundColor Yellow "Renaming tag '$Old' to '$New'"
        Invoke-Expression $cmd
    }
    else
    {
        Write-Host "Would rename tag '$Old' to '$New' with '$cmd'"
    }
}

function grc { gvim (git diff --name-only --diff-filter=U) }
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
        $cmdString = "git diff $diffArgs > $HOME\work\git_patches\$($args[-1])"
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

function gsql
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][int]$CommitCount
    )

    & "git rebase -i HEAD~${CommitCount}";
}

function PruneSquashedBranches
{
    [CmdletBinding( )]
    Param(
    [string]$Branch,
    [switch]$Apply
    )

    if (!$Branch) {
        $Branch = $env:GitBranch
        Write-Host "Defaulting to compare against branch [$Branch]"
    }

    git checkout -q $Branch
    git for-each-ref refs/heads/ "--format=%(refname:short)" | % {
        $mergeBase = (git merge-base $Branch $_)

        $gitTree = (git rev-parse "$_^{tree}")
        $gitCherry = (git cherry $branch "$(git commit-tree $gitTree -p $mergeBase -m _)")
        $squashMerged = $gitCherry[0] -eq '-'
        $topicHead = (git rev-parse --short $_)

        if ($squashMerged)
        {
            if ($Apply)
            {
                (git branch -D $_) | Out-Null
            }

            $deleteMsg = if ($Apply) { "    DELETED" } else { "WILL DELETE"}
            Write-Host -ForegroundColor Red $deleteMsg -NoNewLine
        }
        else
        {
            Write-Host " not merged" -NoNewLine
        }
        Write-Host " ... ($topicHead) $_"
    }
}

function howto-edit-git-exclude { echo "$GITROOT/.git/info/exclude" }

########
# MISC #
########
new-alias pd pushd -Force -Option AllScope
function grep($pattern) { git grep -r --ignore-case $pattern }

function edit-hosts { Start-Process -FilePath vim -ArgumentList c:\windows\system32\drivers\etc\hosts -Verb RunAs }
function type-hosts { type c:\windows\system32\drivers\etc\hosts | sls "^\w" -NoEmphasis }

# net stop beep

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

function PrintNum
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory = $true)][int]$Value,
    [Parameter(Mandatory = $false)][switch]$AsHex,
    [Parameter(Mandatory = $false)][switch]$AsDec
    )

    if (!$AsHex -and !$AsDec)
    {
        $AsHex = $true
        $AsDec = $true
    }

    if ($AsHex)
    {
        $hex = '0x{0:x}' -f $Value
        Write-Host "Hex: $hex"
    }

    if ($AsDec)
    {
        $dec = '{0:d}' -f $Value
        Write-Host "Dec: $dec"
    }
}

function CompareFiles()
{
    Param(
    [Parameter(Mandatory = $true)][string]$fileA,
    [Parameter(Mandatory = $true)][string]$fileB
    )

    $properties = @{
        "Left"=$fileA;
        "Right"=$fileB;
        "Same"=(Get-FileHash $fileA).hash  -eq (Get-FileHash $fileB).hash;
    };

    New-Object -TypeName PSObject -Property $properties
}

function CompareMeasureObject()
{
    Param(
    [Parameter(Mandatory = $true)]$ObjectA,
    [Parameter(Mandatory = $true)]$ObjectB
    )

    <#
    Count             : 1358
    Average           : 125270.397643594
    Sum               : 170117200
    Maximum           : 1017200
    Minimum           : 27100
    StandardDeviation : 58282.3393138254
    Property          : Inc. Duration
    #>

    function PercentDiff
    {
        Param(
        [Parameter(Mandatory = $true)]$ValueName,
        [Parameter(Mandatory = $true)]$ValueA,
        [Parameter(Mandatory = $true)]$ValueB
        )

        $diff = $ValueB - $ValueA;
        $percentDiff = $diff / $valueA;
        $properties = @{
            "Name"=$ValueName;
            "Diff"=$diff;
            "PercentDiff"=$percentDiff;
            "A"=$ValueA;
            "B"=$ValueB;
        };
        return New-Object -TypeName PSObject -Property $properties
    }

    PercentDiff -ValueName "Average" -ValueA $ObjectA.Average -ValueB $ObjectB.Average
    PercentDiff -ValueName "Maximum" -ValueA $ObjectA.Maximum -ValueB $ObjectB.Maximum
    PercentDiff -ValueName "Minimum" -ValueA $ObjectA.Minimum -ValueB $ObjectB.Minimum
    PercentDiff -ValueName "StandardDeviation" -ValueA $ObjectA.StandardDeviation -ValueB $ObjectB.StandardDeviation
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# MISC aliases
new-alias ppm OpenSeeIt.exe -Force -Option AllScope

function GitGrepReplace
{
    param(
        [string]$PathSpec,
        [string]$Original,
        [string]$Replace
        )

    $files = git grep --name-only $Original -- $PathSpec
    $files | % { ((Get-Content -Path $_ -Raw) -Replace $Original,$Replace) | Set-Content -NoNewLine -Path $_ }
}

function GitGrepToVim
{
    param(
        [Parameter(Mandatory)]
        [string]$Pattern
        )

    gvim (git grep --name-only -i $Pattern)
}

function PixClipboardToCsv
{
    return Get-Clipboard | %{$_.Replace("`t", ",")} | ConvertFrom-Csv
}

function AnalyzePixClipboard
{
    PixClipboardToCsv | Measure-Object -Property "Inc. Duration" -Average -Sum -Maximum -Minimum -StandardDeviation
}

function MeasureCsv
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $Input,

        [Parameter(Mandatory)]
        [string]$Property
        )

    $Input | Measure-Object -Property $Property -Average -Sum -Maximum -Minimum -StandardDeviation
}

###########
# Journal #
###########
function Journal
{
    Param(
        [switch]$Alt,
        [string]$Entry
        )

    if ($Alt)
    {
        if (!$env:AltJournalPath)
        {
            throw "Alt journal path not set in ps_side.ps1";
        }
        $journalPath = $env:AltJournalPath
        $journalDescTag = "[alt]"
    }
    else
    {
        if (!$env:JournalPath)
        {
            throw "Journal path not set in ps_side.ps1";
        }
        $journalPath = $env:JournalPath
        $journalDescTag = ""
    }

    if (!(Test-Path $journalPath))
    {
        throw "$journalPath does not exist";
    }

    $requiredExtension = ".jf"
    if ((Get-Item $journalPath).Extension -ne $requiredExtension)
    {
        throw "Journal$journalDescTag file needs '$requiredExtension' extension. Found $journalPath";
    }

    if ($Entry)
    {
        $dateline = (Get-Date -Format "`n[ ddd d MMM yy - h:mm:ss tt ]`n")
        Out-File -InputObject $dateline -Append -FilePath $journalPath  -NoNewline
        Out-File -InputObject "$Entry`n" -Append -FilePath $journalPath -NoNewline
    }
    else
    {
        gvim $journalPath
    }
}
