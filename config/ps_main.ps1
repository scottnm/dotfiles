######################################
#### WARNINGS FOR NEEDED ENV VARS ####
######################################
function VerifyEnvironmentVariable
{
    Param(
        [string]$Name
        )

    if (! (Get-Item -path "Env:$Name" -ErrorAction SilentlyContinue) )
    {
        Write-Error "`$env:$Name not set! Set in system path variables"
    }
}

VerifyEnvironmentVariable "SideProfilePath"

######################################
####          PROFILE START       ####
######################################
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
new-alias vim nvim-qt -Force -Option AllScope
new-alias nvim nvim-qt -Force -Option AllScope

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
# Ensure-Module -Name Posh-Git

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
    if ($currentBranch)
    {
        $env:GitTopic = $currentBranch.Split('/')[-1];
    }
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

    if ($env:CustomPromptPathTrail)
    {
        $statusLine += " :: $(Colored -Color Yellow -Text $env:CustomPromptPathTrail)"
    }

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
        [string]$Remote = "origin",
        [string]$Branch
        )

    UpdateGitBranchVars
    if (!$Branch)
    {
        $Branch = $env:GitBranch
    }

    if ($env:GitBranch)
    {
        git branch --set-upstream-to=$Remote/$Branch $env:GitBranch
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

function grc {
    pushd $env:GitRoot
    $conflictedFiles = @(git diff --name-only --diff-filter=U)
    if ($conflictedFiles.Length -gt 0)
    {
        Write-Host "Opening $($conflictedFiles.Length) file(s) to resolve merge conflicts:"
        foreach ($f in $conflictedFiles)
        {
            Write-Host "    $f"
        }
        gvim $conflictedFiles
    }
    else
    {
        Write-Host "No conflicting files"
    }
    popd
}
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
function gdcw { & git diff --color-words $args }
function gdccw { & git diff --cached --color-words $args }
function gcp
{
    if ($args.Length -lt 2)
    {
        Write-Warning "Usage: gcp [diff args] [patch name]"
        return
    }

    $patchDirectory = $env:GitPatchDirectory
    if (!(Test-Path $patchDirectory))
    {
        Write-Warning "Patch directory `"$patchDirectory`" does not exist!"
        return
    }

    $diffArgs = $args[0..($args.Length - 2)]
    $cmdString = "git diff $diffArgs > $patchDirectory\$($args[-1])"
    cmd /c $cmdString
    echo $cmdString
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

function gbrowse
{
    $url = (git config --get remote.origin.url)
    if ($?)
    {
        start $url
    }
}

function PruneSquashedBranches
{
    [CmdletBinding( )]
    Param(
    [string]$BaseBranch,
    [string[]]$TargetBranches,
    [switch]$WhatIf
    )

    if (!$BaseBranch) {
        $BaseBranch = $env:GitBranch
        Write-Host "Defaulting to compare against branch [$BaseBranch]"
    }

    git checkout -q $BaseBranch

    function PruneInternal
    {
        Param(
            [string]$BaseBranch,
            [string]$TargetBranch
        )
        $mergeBase = (git merge-base $BaseBranch $TargetBranch)

        Write-Host -foregroundcolor cyan "Testing $BaseBranch <- $TargetBranch"
        $gitTree = (git rev-parse "$TargetBranch^{tree}")
        $gitCherry = (git cherry $BaseBranch "$(git commit-tree $gitTree -p $mergeBase -m _)")
        $squashMerged = $gitCherry[0] -eq '-'
        $topicHead = (git rev-parse --short $TargetBranch)

        if ($squashMerged)
        {
            if (!$WhatIf)
            {
                (git branch -D $TargetBranch) | Out-Null
            }

            $deleteMsg = if (!$WhatIf) { "    DELETED" } else { "WILL DELETE"}
            Write-Host -ForegroundColor Red $deleteMsg -NoNewLine
        }
        else
        {
            Write-Host " not merged" -NoNewLine
        }
        Write-Host " ... ($topicHead) $TargetBranch"
    }

    if ($TargetBranches.Count -gt 0)
    {
        foreach ($TargetBranch in $TargetBranches)
        {
            PruneInternal -BaseBranch $BaseBranch -TargetBranch $TargetBranch
        }
    }
    else
    {
        git for-each-ref refs/heads/ "--format=%(refname:short)" | % {
            $targetBranch = $_
            if ($BaseBranch -ne $targetBranch)
            {
                PruneInternal -BaseBranch $BaseBranch -TargetBranch $targetBranch
            }
        }
    }
}

function Git-DeleteRemoteBranch
{
    [CmdletBinding( )]
    Param(
    [Parameter(Mandatory = $true)][string]$Branch,
    [string]$Remote = "origin"
    )

    git push $Remote --delete $Branch

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

function FindAndReplace
{
    param(
        [string[]]$Paths,
        [string]$From,
        [string]$To,
        [switch]$Recurse
        )

    function ReplaceTextInFile {
        param(
            [string]$Path,
            [string]$From,
            [string]$To
            )

        $x = (Get-Content $Path | %{ $_ -Replace $From, $To })
        Set-Content $x -Path:$Path
    }

    Get-ChildItem $Paths -Recurse:$Recurse |
        ? { (sls $From $_).Matches.Count -gt 0 } |
        % { ReplaceTextInFile -Path:$_ -From:$From -To:$To }
}

function PrintNum
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory = $true)][int64]$Value,
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

function DecodeBase64
{
    Param(
    [Parameter(Mandatory = $true)]$Base64String
    )

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String))
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

Function LaunchVs
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("2019", "2022")]
        [string]$Ver,
        [string]$Sln
        )

    $ProgFilesPath = if ($Ver -ge "2022") { $env:ProgramFiles } else { ${env:ProgramFiles(x86)} }
    & "$ProgFilesPath\Microsoft Visual Studio\$Ver\Enterprise\Common7\IDE\devenv.exe" $Sln

}

###########
# Journal #
###########
function Journal
{
    Param(
        [switch]$AddEntry,
        [switch]$Alt,
        [string]$EntryText,
        [string[]]$EntryTags
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

    if ($EntryText)
    {
        $dateline = (Get-Date -Format "`n[ ddd d MMM yy - h:mm:ss tt ]`n")

        Out-File -InputObject $dateline -Append -FilePath $journalPath  -NoNewline
        Out-File -InputObject "$EntryText`n" -Append -FilePath $journalPath -NoNewline

        if ($EntryTags)
        {
            $tagsline = "#" + ($EntryTags -Join "  #") + "`n"
            Out-File -InputObject $tagsline -Append -FilePath $journalPath -NoNewLine
        }
    }
    else
    {
        if ($EntryTags)
        {
            throw "Can't supply `$EntryTags without `$EntryText!";
        }

        if ($AddEntry)
        {
            gvim $journalPath -c "call NewJournalEntry()"
        }
        else
        {
            gvim $journalPath
        }
    }
}

function Test-Image {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string] $Path
        )

    PROCESS {
        $knownHeaders = @{
            jpg = @( "FF", "D8" );
            bmp = @( "42", "4D" );
            gif = @( "47", "49", "46" );
            tif = @( "49", "49", "2A" );
            png = @( "89", "50", "4E", "47", "0D", "0A", "1A", "0A" );
            # pdf = @( "25", "50", "44", "46" );
        }

        # coerce relative paths from the pipeline into full paths
        if($_ -ne $null) {
            $Path = $_.FullName
        }

        # read in the first 8 bits
        $bytes = Get-Content -LiteralPath $Path -AsByteStream -ReadCount 1 -TotalCount 8 -ErrorAction Ignore
        $retval = $false
        foreach($key in $knownHeaders.Keys) {
            # make the file header data the same length and format as the known header
            $fileHeader = $bytes |
            Select-Object -First $knownHeaders[$key].Length |
            ForEach-Object { $_.ToString("X2") }
            if($fileHeader.Length -eq 0) {
                continue
            }
            # compare the two headers
            $diff = Compare-Object -ReferenceObject $knownHeaders[$key] -DifferenceObject $fileHeader
            if(($diff | Measure-Object).Count -eq 0) {
                $retval = $true
            }
        }
        return $retval
    }
}

function Recolor-IARBuildOutput {
    [cmdletbinding()]
    param(
    [parameter(Mandatory = $true, ValueFromPipeline = $true)]
    $pipelineInput
    )

    Begin {
        $warnCount = 0;
        $errCount = 0;
    }

    Process {
        ForEach ($input in $pipelineInput) {
            $color = ""
            if ($input.Contains("Warning["))
            {
                $color = "Yellow"
                $warnCount += 1;
            }
            elseif ($input.Contains("Error["))
            {
                $color = "Red"
                $errCount += 1;
            }
            else
            {
                $color = "White"
            }

            Write-Host $input -foregroundcolor $color
        }
    }

    End {
        Write-Host "-------------------------------------------------------------------------------"
        if ($warnCount -gt 0) { Write-Host "Warnings: $warnCount" -ForegroundColor Yellow }
        if ($errCount -gt 0) { Write-Host "Errors:   $errCount" -ForegroundColor Red }
    }
}

function Git-GrepChanges
{
    param(
        [string]$Start,
        [string]$End = "",
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        [switch]$CaseSensitive,
        [switch]$NameOnly
        )

    if (!$Start)
    {
        if (!(git remote).Contains("origin"))
        {
            throw "remote named 'origin' not found (non-origin remotes not yet supported)"
        }

        $remote = "origin"
        $baseRemoteBranchName = (git symbolic-ref --short refs/remotes/$remote/HEAD)
        $Start = $baseRemoteBranchName.substring("$remote/".Length) # e.g. origin/master -> master
    }

    $CaseSensitiveOption = if (!$CaseSensitive) { "-i" } else { $null }
    $NameOnlyOption = if ($NameOnly) { "--name-only" } else { $null }
    git diff --name-only "$Start..$End" | %{ git grep $NameOnlyOption $CaseSensitiveOption $Pattern -- $_ }
}

function Git-RebaseTakeChanges
{
    [CmdletBinding( )]
    param(
    [Parameter(Mandatory)]
    [ValidateSet("Base", "Topic")]
    [string]$Changes,
    [Parameter(Mandatory)]
    [string]$Path
    )

    $changeSourceFlag = ""
    if ($Changes -eq "Base")
    {
        $changeSourceFlag = "--ours"
    }
    elseif ($Changes -eq "Topic")
    {
        $changeSourceFlag = "--theirs"
    }
    else
    {
        throw "Invalid changes type '$Changes'"
    }

    git checkout $changeSourceFlag $Path
    git add $Path

    write-verbose "Took $Changes for $Path"
}

function Git-RebaseTakeChanges
{
    [CmdletBinding( )]
    param(
    [Parameter(Mandatory)]
    [ValidateSet("Base", "Topic")]
    [string]$Changes,
    [Parameter(Mandatory)]
    [string]$Path
    )

    $changeSourceFlag = ""
    if ($Changes -eq "Base")
    {
        $changeSourceFlag = "--ours"
    }
    elseif ($Changes -eq "Topic")
    {
        $changeSourceFlag = "--theirs"
    }
    else
    {
        throw "Invalid changes type '$Changes'"
    }

    git checkout $changeSourceFlag $Path
    git add $Path

    write-verbose "Took $Changes for $Path"
}

function Git-RebaseTakeAllChanges
{
    [CmdletBinding( )]
    param(
    [Parameter(Mandatory)]
    [ValidateSet("Base", "Topic")]
    [string]$Changes
    )

    pushd $env:GitRoot
    $conflictedFiles = @(git diff --name-only --diff-filter=U)
    if ($conflictedFiles.Length -gt 0)
    {
        foreach ($f in $conflictedFiles)
        {
            Git-RebaseTakeChanges -Changes $Changes -Path $f
        }
    }
    else
    {
        Write-Host "No conflicting files"
    }
    popd
}

function View-Json {
    param(
        [string]$File,
        [string]$StrInput,
        [int]$Depth = 2
    )

    if (!$File -and !$StrInput) {
        throw "One of `$File or `$StrInput required"
    }

    if ($File -and $StrInput) {
        throw "Only one of `$File or `$StrInput allowed"
    }

    $data = $StrInput
    if (!$data) {
        $data = Get-Content $File
    }

    write-output $data |  ConvertFrom-Json | ConvertTo-Json -Depth $Depth
}

function New-OneDriveGitRepo {
    param(
    [Parameter(Mandatory=$true)]
    [string]$reponame,
    [string]$onedrivelocation = $null
    )

    if (!$onedrivelocation)
    {
        $onedrivelocation = "$env:OneDrive\projects"
    }

    function diag($msg) { Write-Host -foregroundcolor cyan $msg }

    diag "Creating onedrive bare repo @ $(Join-Path $onedrivelocation $reponame)..."
    pushd $onedrivelocation
    mkdir $reponame
    cd $reponame
    git init --bare
    git symbolic-ref HEAD refs/heads/main
    popd
    diag "...created"

    diag "Creating local repo @ $(Join-Path $pwd $reponame)..."
    mkdir $reponame
    cd $reponame
    git init
    diag "    ...setting branch and remote"
    git branch -m main
    git remote add onedrive file://"$(Join-Path $onedrivelocation $reponame)"
    diag "    ...creating first commit and pushing"
    echo "" > .gitignore
    git add .gitignore
    git commit -m "first commit"
    git push
    diag "...done"
}
