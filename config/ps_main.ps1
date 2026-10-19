######################################
#### WARNINGS FOR NEEDED ENV VARS ####
######################################
function VerifyEnvironmentVariable
{
    Param(
        [string]$Name,
        [string]$EnvSkipKey
        )

    if (Test-Path "Env:$Name") { return; }

    if ($EnvSkipKey)
    {
        if (Test-Path "Env:$EnvSkipKey") { return; }

        Write-Error "`$env:$Name not set and `$env:$EnvSkipKey not found! Set in system path variables"
    }
    else
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

$PlatformPaths = @{
    HostsFilePath = @{ Default="/etc/hosts"; Windows="c:\windows\system32\drivers\etc\hosts" };
}

$PlatformPaths.Keys | % {
    $varName = $_
    $varValue = $null

    $varPlatformData = $PlatformPaths[$varName]

    if ($IsLinux) {
        if ($varPlatformData.Contains("Linux")) {
            $varValue = $varPlatformData["Linux"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }
    elseif ($IsMacOS) {
        if ($varPlatformData.Contains("MacOS")) {
            $varValue = $varPlatformData["MacOS"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }
    else { # Windows; don't bother doing IsWindows check for Powershell5 compat
        if ($varPlatformData.Contains("Windows")) {
            $varValue = $varPlatformData["Windows"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }

    Set-Item -Path "Env:\$varName" -Value $varValue
}

$PlatformAliases = @{
    tedit = @{ Default="vim"; Windows="gvim" };
    dvim = @{ Default="vim"; Windows="gvim" };
}

$PlatformAliases.Keys | % {
    $varName = $_
    $varValue = $null

    $varPlatformData = $PlatformAliases[$varName]

    if ($IsLinux) {
        if ($varPlatformData.Contains("Linux")) {
            $varValue = $varPlatformData["Linux"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }
    elseif ($IsMacOS) {
        if ($varPlatformData.Contains("MacOS")) {
            $varValue = $varPlatformData["MacOS"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }
    else { # Windows; don't bother doing IsWindows check for Powershell5 compat
        if ($varPlatformData.Contains("Windows")) {
            $varValue = $varPlatformData["Windows"];
        } else {
            $varValue = $varPlatformData["Default"];
        }
    }

    New-Alias -Name $varName -Value $varValue -Force -Option AllScope
}

function Exit-AlternateScreenBuffer {
    echo "`e[?1049l"
}
New-Alias -Name Fix-ScrollWheelScrollingTerminalHistory -Value Exit-AlternateScreenBuffer -Force -Option AllScope
New-Alias -Name FixScrollWheelScrollingTerminalHistory -Value Exit-AlternateScreenBuffer -Force -Option AllScope

# DevEnv edit paths
function Edit-Profile {
    param(
    [ValidateSet("gvim", "nvim", "code", "dvim")]
    [string]$Editor = "dvim"
    )
    & $Editor (Get-Profiles)
}

function Get-Profiles {
    return @($profile, $env:SideProfilePath)
}

function Edit-Vimrc { dvim $HOME\_vimrc }
function Edit-GhciConf { tedit $env:APPDATA\ghc\ghci.conf }
function Edit-Hosts { tedit c:\windows\system32\drivers\etc\hosts }
function Edit-GitConfig {
    Param([switch]$Global)
    $editArgs = [System.Collections.ArrayList]@()
    if ($Global) { $editArgs.Add("--global") | Out-Null }
    $editArgs.Add("-e") | Out-Null
    write-host -foregroundcolor darkgray "git config $editArgs"
    git config @editArgs
}
function Edit-TopicNotes {
    param(
    [ValidateSet("gvim", "nvim")]
    [string]$Editor = "nvim",
    [string]$Topic
    )

    if (-not $Topic) {
        $Topic = $env:GitTopic
        if (-not $Topic)
        {
            throw "Topic not set: not implicit git topic branch and no `$Topic provided"
        }
    }

    $path = Join-Path -path $env:TopicNotesDir -ChildPath "${env:GitTopic}_notes.md"
    & $Editor $path
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
    if ($env:OverrideWindowTitle)
    {
        [System.Console]::Title = $env:OverrideWindowTitle;
        return;
    }

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

    if ($PSVersionTable.PSVersion.Major -le 5) {
        return $Text
    }

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
    $savedLastExitCode = if ($LASTEXITCODE) { $LASTEXITCODE } else { 0 }

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
        $gitBranchColor = if ("$env:GitBranch".Contains("Detached:")) {"Yellow"} else {"Green"}
        $branchPrompt = Colored -Text $env:GitBranch -Color $gitBranchColor
        $statusLine += " :: $branchPrompt"
    }
    $statusLine += " :: $(Get-Date)"

    $exitCodeText = $savedLastExitCode
    if ($savedLastExitCode -ne 0)
    {
        $exitCodeText = (Colored -Text $savedLastExitCode -Color Red)
    }

    $statusLine += " :: ($exitCodeText)
 "

    UpdateWindowTitle;

    Write-Host $statusLine -nonewline
    $prompt = (Colored -Text $PromptChar -Color Yellow)
    return $prompt
}
$PromptChar = if ($PSVersionTable.PSVersion.Major -le 5) { "$ " } else { "λ " }


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
        dvim $conflictedFiles
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
    if ($diffArgs.Count -eq 1)
    {
        $diffArg = $diffArgs[0]
        if ($diffArg -match '^[a-zA-Z0-9]+$')
        {
            $commitHash = $diffArg
            $diffArgs = @( "$($commitHash)^..$($commitHash)" )
        }
    }

    $patchPath = Join-Path $patchDirectory $args[-1]

    write-host -foregroundcolor DarkGray "git diff $diffArgs > $patchPath"
    git diff @diffArgs > $patchPath

    write-host -foregroundcolor DarkGray ""
    Get-Content $patchPath | write-host -foregroundcolor DarkGray

    write-host -foregroundcolor cyan "new patch @ $patchPath"
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
function glp { & git logp $args }

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

# I've migrated this script to a proper git alias. Keep it around "just in case" but going forward I should try to use the git alias instead
# Delete this at the next opportunity after July 1s 2026
function PruneSquashedBranches-Deprecated
{
    [CmdletBinding( )]
    Param(
    [string]$BaseBranch,
    [string[]]$TargetBranches,
    [switch]$WhatIf
    )

    if (!$BaseBranch) {
        $OriginHeadRef = (git symbolic-ref refs/remotes/origin/HEAD)
        write-host "Default base branch refs: $OriginHeadRef" -foregroundcolor darkgray
        $BaseBranch = $OriginHeadRef.Substring("refs/remotes/origin/".Length)
        Write-Host "Defaulting to compare against branch [$BaseBranch]"
    }

    $CurrentBranch = git rev-parse --abbrev-ref HEAD
    if ($CurrentBranch -ne $BaseBranch) {
        git checkout -q $BaseBranch
        write-verbose "git checkout -q $BaseBranch"
    }

    git pull -q
    write-host "git pull -q" -foregroundcolor darkgray

    function PruneInternal
    {
        Param(
            [string]$BaseBranch,
            [string]$TargetBranch
        )
        $mergeBase = (git merge-base $BaseBranch $TargetBranch)

        Write-Host -foregroundcolor cyan "Testing $BaseBranch <- $TargetBranch"

        $gitTree = (git rev-parse "$TargetBranch^{tree}")
        write-verbose "git rev-parse `"$TargetBranch^{tree}`""

        $gitCherryBase = git commit-tree $gitTree -p $mergeBase -m _
        write-verbose "git commit-tree $gitTree -p $mergeBase -m _ = $gitCherryBase"

        $gitCherry = (git cherry $BaseBranch $gitCherryBase)
        write-verbose "git cherry $BaseBranch $gitCherryBase"
        write-verbose "git cherry[0] = $($gitCherry[0])"

        $squashMerged = $gitCherry[0] -eq '-'
        write-verbose "`$gitCherry[0] -eq '-' = $squashMerged"

        $topicHead = (git rev-parse --short $TargetBranch)
        write-verbose "git rev-parse --short $TargetBranch = $topicHead"

        if ($squashMerged)
        {
            if (!$WhatIf)
            {
                (git branch -D $TargetBranch) | Out-Null
                write-verbose "(git branch -D $TargetBranch) | Out-Null"
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

    write-verbose "git fetch --all --prune"
    git fetch --all --prune
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
function ggrep($pattern) { git grep -r --ignore-case $pattern }
function psgrep { param([string]$filesPattern,[string]$pattern) sls -path $filesPattern -pattern $pattern }

function edit-hosts { Start-Process -FilePath vim -ArgumentList c:\windows\system32\drivers\etc\hosts -Verb RunAs }
function type-hosts { type c:\windows\system32\drivers\etc\hosts | sls "^\w" -NoEmphasis }

# net stop beep

function Set-WinHttpProxy
{
    param([switch]$Clear)
    if ($Clear) {
        write-host -foregroundcolor darkgray 'netsh winhttp reset proxy'
        netsh winhttp reset proxy
    } else {
        write-host -foregroundcolor darkgray 'netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"'
        netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"
    }
}

function Clear-WinHttpProxy { Set-WinHttpProxy -Clear }

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
    [Parameter(Mandatory = $true)][System.UInt64]$Value,
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

function Decode-Base64
{
    Param(
    [Parameter(Mandatory = $true)]$Base64String
    )

    return [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Base64String))
}
function Encode-Base64
{
    Param(
    [string]$FilePath,
    [Byte[]]$Bytes
    )

    if (-not ($FilePath -or $Bytes)) {
        throw "Must provide filepath or raw bytes"
    }

    if ($FilePath) {
        $Bytes = (Get-Content $FilePath -AsByteStream)
    }

    return [Convert]::ToBase64String($Bytes)
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

    dvim (git grep --name-only -i $Pattern)
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
        [ValidateSet("gvim", "nvim")]
        [string]$Editor = "nvim",
        [switch]$AddEntry,
        [switch]$Alt,
        [string]$Search,
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

    if ($Search)
    {
        select-string -Path $journalPath -Pattern $Search
    }

    if ((!$EntryText) -and (!$Search))
    {
        if ($AddEntry)
        {
            & $Editor $journalPath -c "call NewJournalEntry()"
        }
        else
        {
            & $Editor $journalPath
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

    $filesChanged = @(git diff --name-only "$Start..$End")
    if ($NameOnly)
    {
        $filesChanged | %{ git grep --name-only $CaseSensitiveOption $Pattern -- $_ }
    }
    else
    {

        $filesChanged |
            % { git grep --line-number  $CaseSensitiveOption $Pattern -- $_ } |
            % {
                $m=(sls -InputObject $_ -Pattern "(\S+:)\s*(\S.*)").Matches;
                "$($m.Groups[1].Value)`n$($m.Groups[2].Value)`n";
            }
    }
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

function rsls {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePattern,
        [Parameter(Mandatory=$true)]
        [string]$SearchPattern
    )

    dir $FilePattern -rec | %{sls -InputObject $_ -Pattern $SearchPattern }
}

function New-OneDriveGitRepo {
    param(
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [string]$OneDriveHome,
    [string]$OneDriveRepoRoot = "projects",
    [string]$OneDriveGitRemoteName = "onedrive",
    [string]$DefaultGitBranchName = "main"
    )

    if (!$OneDriveHome)
    {
        if (!$env:OneDrive)
        {
            throw "Must specify -OneDriveHome if `$env:OneDrive not defined"
        }
        $OneDriveHome = $env:OneDriveHome
    }


    $OneDriveRepoPath = (Join-Path $OneDriveHome $OneDriveRepoRoot)
    $OneDriveRepoPath = (Get-Item $OneDriveRepoPath).FullName # avoid any problems with ~ references

    function diag($msg) { Write-Host -foregroundcolor cyan $msg }

    $originalLocation = Get-Location

    try
    {
        cd $OneDriveRepoPath
        diag "Creating onedrive bare repo @ $(Join-Path $OneDriveRepoPath $RepoName)..."
        mkdir $RepoName
        cd $RepoName
        git init --bare
        git symbolic-ref HEAD "refs/heads/$DefaultGitBranchName"
        diag "...created"

        Set-Location $originalLocation
        diag "Creating local repo @ $(Join-Path $pwd $RepoName)..."
        mkdir $RepoName
        cd $RepoName
        git init
        diag "    ...setting branch and remote"
        git branch -m $DefaultGitBranchName
        git remote add $OneDriveGitRemoteName file://"$(Join-Path $OneDriveRepoPath $RepoName)"
        diag "    ...creating first commit and pushing"
        echo "" > .gitignore
        git add .gitignore
        git commit -m "first commit"
        git push -u $OneDriveGitRemoteName $DefaultGitBranchName
        diag "...done"
    }
    finally
    {
        Set-Location $originalLocation
    }

}

function SlsObjectMap {
    param(
    [Parameter(Mandatory)]
    [System.Text.RegularExpressions.Match]$MatchResult,

    [string[]]$Names,

    [ValidateSet("int", "string")]
    [string[]]$Types
    )


    if ($Names.Length -lt $Types.Length)
    {
        throw "Must have at least as many `$Names as `$Types"
    }

    $mappedObj = @{}
    for ($groupIndex = 1; $groupIndex -lt $MatchResult.Groups.Count; $groupIndex++)
    {
        $i = $groupIndex-1
        $name = "Group_$i"
        if ($Names.Length -gt $i)
        {
            $name = $Names[$i]
        }

        $type = [string]
        if ($Types.Length -gt $i)
        {
            $type = $Types[$i]
        }

        $valueStr = $MatchResult.Groups[$i+1].Value
        $value = $valueStr
        if ($Types.Length -gt $i)
        {
            $type = $Types[$i]
            if ($type -eq "int")
            {
                $value = [int]$valueStr;
            }
        }

        $mappedObj.add($name, $value)
    }

    return [pscustomobject]$mappedObj
}

function Do-PCap {
    netsh trace start "capture=yes"
    Read-Host "Run your scenario. Hit any key to stop the trace"
    netsh trace stop
}

function Mirror-Copy {
    param(
        [Parameter(Mandatory)]
        [string]$Source,
        [string]$Destination,
        [switch]$NoCompress,
        [switch]$Purge,
        [int]$MinFileSizeBytes,
        [int]$MaxFileSizeBytes
        )

    if (!($Destination))
    {
        $cwdLeaf = Split-Path ($pwd.Path) -Leaf
        $defaultDestination = Split-Path $Source -Leaf
        if ($cwdLeaf -eq $defaultDestination)
        {
            write-host -foregroundcolor yellow "WARNING: Mirror copy nesting detected!"
            Read-Host "Press [enter] to proceed or Ctrl-C to quit"
        }

        $Destination = Join-Path $pwd $defaultDestination
        write-host -foregroundcolor darkgray "Default copying to $Destination"
    }

    $args = New-Object System.Collections.Generic.List[System.Object]
    $args.Add($Source)
    $args.Add($Destination)
    $args.Add("/S")
    if (!$NoCompress)
    {
        $args.Add("/COMPRESS")
    }

    if ($Purge)
    {
        $args.Add("/PURGE")
    }

    if ($MinFileSizeBytes)
    {
        $args.Add("/MIN:$MinFileSizeBytes")
    }

    if ($MaxFileSizeBytes)
    {
        $args.Add("/MAX:$MaxFileSizeBytes")
    }

    write-host -foregroundcolor darkgray "robocopy $args"
    robocopy @args
}

# [l][s][s]imple
function lss {
    param([string[]]$Props = @("Name", "LastWriteTime"))
    get-childitem @args | select-object $Props
}

function Get-LineEndingType {
    param(
        [string]$FilePath
        )

    $content = Get-Content -Path $FilePath -AsByteStream
    if ($content -contains 13) {
        if ($content -contains 10) {
            return "DOS (CRLF)"
        } else {
            return "Classic Mac (CR)"
        }
    } else {
        if ($content -contains 10){
            return "Unix (LF)"
        } else {
            return "File is empty or contains no line breaks"
        }
    }
}

function Filter-LineEndingType {
    param(
        [string]$FilePath,
        [ValidateSet("DOS","Unix","MacClassic")]
        [string]$LineEndingType
        )

    $content = Get-Content -Path $FilePath -AsByteStream
    if ($content -contains 13) {
        if ($content -contains 10) {
            return $LineEndingType -eq "DOS"
        } else {
            return $LineEndingType -eq "MacClassic"
        }
    } else {
        if ($content -contains 10){
            return $LineEndingType -eq "Unix"
        } else {
            return $false
        }
    }
}

function Convert-WinFileTimeTimestampToUnixTime
{
    param([System.Int64]$WinFileTime)

    $WINDOWS_TICK = 10000000
    $SEC_TO_UNIX_EPOCH = 11644473600
    $unixTime = ([System.Int64]($WinFileTime / $WINDOWS_TICK) - $SEC_TO_UNIX_EPOCH)
    $datetime = [datetimeoffset]::FromUnixTimeSeconds($unixTime)

    write-host "Unix time: $unixTime"
    write-host "datetime:  $datetime"
}

function Convert-UnixTimeToClock
{
    param(
        [Parameter(Mandatory)]
        [int]$UnixTime
        )

    [datetimeoffset]::FromUnixTimeMilliseconds(1000 * $UnixTime)
}

$AndroidEmulatorExe = "$env:ANDROID_HOME\emulator\emulator.exe"
new-alias Launch-AndroidEmulatorRaw $AndroidEmulatorExe -Force -Option AllScope
function Launch-AndroidEmulator
{
    param(
        [string]$DeviceName
        )

    if ($DeviceName)
    {
        Start-Process $AndroidEmulatorExe -ArgumentList @("-avd", $DeviceName)
    }
    else
    {
        Launch-AndroidEmulatorRaw "-list-avds"
    }
}

        <#
        Common Options:
Create: tar.exe -c [options] [<file> | <dir> | @<archive> | -C <dir> ]
  <file>, <dir>  add these items to archive
  -z, -j, -J, --lzma  Compress archive with gzip/bzip2/xz/lzma
  --format {ustar|pax|cpio|shar}  Select archive format
  --exclude <pattern>  Skip files that match pattern
  -C <dir>  Change to <dir> before processing remaining files
  @<archive>  Add entries from <archive> to output
List: tar.exe -t [options] [<patterns>]
  <patterns>  If specified, list only entries that match
Extract: tar.exe -x [options] [<patterns>]
  <patterns>  If specified, extract only entries that match
  -k    Keep (don't overwrite) existing files
  -m    Don't restore modification times
  -O    Write entries to stdout, don't restore to disk
  -p    Restore permissions (including ACLs, owner, file flags)
  #>
function Expand-Tar {
    [CmdletBinding( )]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$DestDir,
        [Parameter(Mandatory)]
        [ValidateSet("Create", "ReplaceAdd", "List", "Update", "Extract")]
        [string]$Mode,
        [switch]$Use512ByteRecords,
        [switch]$Interactive
        )

    $localVerbose = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    if (!$DestDir)
    {
        $DestDir = (Join-Path "."  ((Get-Item $Path).BaseName + "_tar"))
    }

    switch ($Mode)
    {
        "Create" { $ModeArg = "-c" }
        "ReplaceAdd" { $ModeArg = "-r" }
        "List" { $ModeArg = "-t" }
        "Update" { $ModeArg = "-u" }
        "Extract" { $ModeArg = "-x" }
    }
    $tarArgs = [System.Collections.ArrayList]@()
    $tarArgs.Add("-f") | Out-Null
    $tarArgs.Add($Path) | Out-Null
    $tarArgs.Add($ModeArg) | Out-Null
    if ($localVerbose) { $tarArgs.Add("-v") | Out-Null }
    if ($Interactive) { $tarArgs.Add("-w") | Out-Null }
    if ($Use512ByteRecords) { $tarArgs.Add("-b") }

    if ($Mode -eq "Extract")
    {
        mkdir -force $DestDir | Out-Null
        $tarArgs.Add("-C") | Out-Null
        $tarArgs.Add($DestDir) | Out-Null
    }

    write-host -foregroundcolor darkgray "tar $tarArgs"
    tar @tarArgs
}

$MaximumHistoryCount = 32767 # max amount of powershell history

function Remove-SystemPath
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$OldPath,
        [ValidateSet("User", "Machine", "Process")]
        [string]$PathScope = "User",
        [switch]$Quiet,
        [switch]$NoParentScopes
        )

    function MatchesOldPath {
        param([string]$Path)
        return ($Path -eq $OldPath) -or ($Path -eq $OldPath.trim("\\"))
    }


    $scopesToTest = @($PathScope)
    if ($PathScope -ne "Process" -and (-not $NoParentScopes))
    {
        $scopesToTest += "Process"
    }

    foreach ($nextScope in $scopesToTest) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", $nextScope)
        $pathChunks = ($currentPath -split ";").trim("\\");
        $remainingPathChunks = $pathChunks | ? { -not (MatchesOldPath -Path $_) }
        Write-Verbose "Path chunks remaining: $remainingPathChunks"
        $removedPathChunks = $pathChunks | ? { MatchesOldPath -Path $_ }
        Write-Verbose "Path chunks to remove: $removedPathChunks"
        if (-not $removedPathChunks)
        {
            if (! $Quiet)
            {
                Write-Host -ForegroundColor DarkYellow "$OldPath does not exist in $nextScope path"
            }
            continue;
        }

        if ($PSCmdlet.ShouldProcess("Remove $removedPathChunks from `$PATH in scope $nextScope")) {
            $newPath = $remainingPathChunks -join ";"
            Write-Verbose "New Path: $newPath"
            [Environment]::SetEnvironmentVariable("Path", $newPath, $nextScope)
            Write-Host "Removed Path from $nextScope path."
        }
    }
}

function Clean-Path {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [ValidateSet("User", "Machine", "Process")]
        [string]$PathScope = "User",
        [switch]$Quiet,
        [switch]$NoParentScopes
        )

    $scopesToTest = @($PathScope)
    if ($PathScope -ne "Process" -and (-not $NoParentScopes))
    {
        $scopesToTest += "Process"
    }

    foreach ($nextScope in $scopesToTest) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", $nextScope)
        $pathChunks = ($currentPath -split ";") | %{ $_.trim("\\"); }
        $newPathChunks = @()
        $removedPathChunks = [System.Collections.Hashtable]@{}
        $seenPathChunks = [System.Collections.Hashtable]@{}

        foreach ($pathChunk in $pathChunks) {
            if ($pathChunk.Trim() -eq "") {
                continue
            }

            if ($seenPathChunks.Contains($pathChunk)) {
                $removedPathChunks[$pathChunk] = $true
                continue
            }

            $seenPathChunks[$pathChunk] = $true
            $newPathChunks += $pathChunk
        }

        if (-not $removedPathChunks)
        {
            if (! $Quiet)
            {
                Write-Host -ForegroundColor DarkGray "$Path already clean in Scope: $nextScope"
            }
            continue;
        }

        if ($PSCmdlet.ShouldProcess("Remove $($removedPathChunks.Keys | %{"'$_'"}) from `$PATH in scope $nextScope")) {
            $newPath = $newPathChunks -join ";"
            Write-Verbose "New Path: $newPath"
            [Environment]::SetEnvironmentVariable("Path", $newPath, $nextScope)
            Write-Host "Cleaned Path in $nextScope scope."
        }
    }
}

function Update-SystemPath
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$AdditionalPath,
        [ValidateSet("User", "Machine", "Process")]
        [string]$PathScope = "User",
        [switch]$Quiet
        )

    $currentPath = [Environment]::GetEnvironmentVariable("Path", $PathScope)
    $pathChunks = ($currentPath -split ";").trim("\\");
    if ($pathChunks.Contains($AdditionalPath.trim("\\")))
    {
        if (! $Quiet)
        {
            Write-Host -ForegroundColor DarkYellow "$AdditionalPath already exists in $PathScope path"
        }
        return;
    }

    $updatedPath = $currentPath + ";" + $AdditionalPath
    [Environment]::SetEnvironmentVariable("Path", $updatedPath, $PathScope)
    Write-Host "Path added successfully to $PathScope path."

    if ($PathScope -ne "Process")
    {
        Update-SystemPath -Quiet -AdditionalPath:$AdditionalPath -PathScope:"Process"
    }
}

function Set-SystemEnvVar
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$VarName,
        [Parameter(Mandatory=$true)]
        [string]$VarValue,
        [ValidateSet("User", "Machine", "Process")]
        [string]$PathScope = "User",
        [switch]$Force
        )

    $currentVar = [Environment]::GetEnvironmentVariable($VarName, $PathScope)
    if ($currentVar)
    {
        if (!$Force)
        {
            throw "$VarName already has value '$currentVar'"
        }

        Write-Host -ForegroundColor DarkYellow "$VarName already has value '$currentVar'. Overwriting..."
    }
    [Environment]::SetEnvironmentVariable($VarName, $VarValue, $PathScope)
    if ($PathScope -ne "Process")
    {
        [Environment]::SetEnvironmentVariable($VarName, $VarValue, "Process")
    }
}

function ReadElfSectionScan
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$FileGlob,
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        [switch]$NoRecurse
        )

    $Recurse = ! $NoRecurse
    $files = dir $FileGlob -Recurse:$Recurse
    foreach ($file in $files)
    {
        readelf -S $file | sls -Pattern $Pattern | %{
            write-host "$($file): $_"
        }
    }
}

function Unlock-MacOsKeychain {
    security unlock-keychain "$HOME/Library/Keychains/login.keychain"
}

function Get-1PasswordValue {
    param(
        [string]$ItemName,
        [string]$FieldName = "password"
        )
    (op item get $ItemName --format json --fields $FieldName | ConvertFrom-Json).value
}

function Log-App {
    param(
    [string]$AppNamePattern,
    [switch]$SkipClear
    )

    $adbPids = @(adb shell ps | sls -pattern "\S+\s+(\d+).*$AppNamePattern" | %{[int]$_.Matches[0].Groups[1].value})
    if ($adbPids.Count -eq 0) {
        throw "test app not running!"
    } elseif ($adbPids.Count -gt 1) {
        throw "multiple test app instances running?"
    }

    $appPid = $adbPids[0]

    clear;
    if (! $SkipClear)
    {
        write-host -foregroundcolor darkgray "adb logcat --clear"
        adb logcat --clear
        if (!$?) {
            throw "Failed to clear logcat"
        }
    }

    write-host -foregroundcolor darkgray "adb logcat --pid=$appPid"
    adb logcat --pid=$appPid
}

# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
# Inlining the template into the profile shaves off ~10ms (25%).
$script:__COREUTILS__ = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@(
        'arch', 'b2sum', 'base32', 'base64', 'basename',
        'basenc', 'cat', 'cksum', 'comm', 'cp',
        'csplit', 'cut', 'date', 'df', 'dirname',
        'du', 'echo', 'env', 'expr', 'factor',
        'false', 'find', 'fmt', 'fold', 'grep',
        'head', 'hostname', 'join', 'la', 'link',
        'ln', 'ls', 'md5sum', 'mkdir', 'mktemp',
        'mv', 'nl', 'nproc', 'numfmt', 'od',
        'pathchk', 'pr', 'printenv', 'printf', 'ptx',
        'pwd', 'readlink', 'realpath', 'rm', 'rmdir',
        'seq', 'sha1sum', 'sha224sum', 'sha256sum', 'sha384sum',
        'sha512sum', 'shuf', 'sleep', 'sort', 'split',
        'stat', 'sum', 'tac', 'tail', 'tee',
        'test', 'touch', 'tr', 'true', 'truncate',
        'tsort', 'unexpand', 'uniq', 'unlink', 'uptime',
        'wc', 'xargs', 'yes'
    ),
    [System.StringComparer]::OrdinalIgnoreCase
)

$script:__COREUTILS_FAST_SKIP__ = [regex]::new(
    '\b(?:' + ($script:__COREUTILS__ -join '|') + ')\b',
    [System.Text.RegularExpressions.RegexOptions]::Compiled -bor `
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
)

# Casting the scriptblock to Func<Ast,bool> once and reusing it avoids the
# per-FindAll scriptblock-to-delegate wrapping overhead (~1.7x faster).
$script:__COREUTILS_CMD_PREDICATE__ = [System.Func[System.Management.Automation.Language.Ast, bool]] {
    param($n) $n -is [System.Management.Automation.Language.CommandAst]
}

$script:__COREUTILS_ARG_SPECIAL__ = [char[]] @("'", '"', '`', '$')

# Wrap arguments into quotes. By being a function we can properly handle $variables.
# As per MSVCRT, any `\` before `"` must be doubled to escape them.
function global:__coreutils_q {
    param($s)
    '"' + (([string]$s) -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
}

# PowerShell tokenizes `*"a"*` as [BareWord] instead of the expected [DoubleQuoted, BareWord, DoubleQuoted].
# To work around that we use... regex. Group 1 = 'single', 2 = "double", 3 = `escape, 4 = bare run.
$script:__COREUTILS_ARG_RX__ = [regex]::new(
    "'((?:[^']|'')*)'|""((?:[^""``]|""""|``.)*)""|``(.)|([^'""``]+)",
    [System.Text.RegularExpressions.RegexOptions]::Compiled
)
$script:__COREUTILS_ARG_EVAL__ = [System.Text.RegularExpressions.MatchEvaluator] {
    param($m)
    if ($m.Groups[1].Success) {
        # Single-quoted: literal. PS '' -> ', then MSVCRT-quote.
        $body = $m.Groups[1].Value.Replace("''", "'")
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[2].Success) {
        # Double-quoted: collapse PS quote-escapes to raw " / ', let ExpandString
        # resolve `n / `t / $var, then MSVCRT-quote.
        $body = $m.Groups[2].Value.
        Replace('`"', '"').
        Replace("``'", "'").
        Replace('""', '"')
        $body = $ExecutionContext.InvokeCommand.ExpandString($body)
        if ($body -match '^(.*?)(\\+)$') {
            return '"' + ($matches[1] -replace '(\\*)"', '$1$1\"') + '"' + $matches[2]
        }
        return '"' + ($body -replace '(\\*)"', '$1$1\"') + '"'
    }
    if ($m.Groups[3].Success) {
        # Backtick-escaped char outside a string: " -> \"; everything else
        # becomes a one-char quoted region so glob metas stay literal.
        $c = $m.Groups[3].Value
        if ($c -eq '"') {
            return '\"'
        }
        return '"' + $c + '"'
    }
    # Bare run: passed through unquoted so coreutils can glob it; expand $vars.
    return $ExecutionContext.InvokeCommand.ExpandString($m.Groups[4].Value)
}

# PSConsoleHostReadLine override that rewrites coreutils command names to their
# .cmd equivalents after PSReadLine returns (history keeps the original).
#
# Why .cmd over .exe: PSNativeCommandArgumentPassing = 'Windows' results in a behavior
# where passing bare quotes to CreateProcess() is impossible. This prevents us from
# passing "*" as "*" to coreutils and instead will be given as a bare *.
# This causes it to treat it as a glob pattern. "*.cmd" files however are automatically
# treated as PSNativeCommandArgumentPassing = 'Legacy', which preserves quotes.
# It is the only possible workaround and the only way coreutils can work at all.
function PSConsoleHostReadLine {
    [System.Diagnostics.DebuggerHidden()]
    param()

    $lastRunStatus = $?
    Microsoft.PowerShell.Core\Set-StrictMode -Off
    $line = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine($host.Runspace, $ExecutionContext, $lastRunStatus)

    # If the line contains no coreutils name, we don't need to parse the AST at all.
    if (-not $script:__COREUTILS_FAST_SKIP__.IsMatch($line)) {
        return $line
    }

    $ast = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
    $commands = $ast.FindAll($script:__COREUTILS_CMD_PREDICATE__, $true)

    # Process right-to-left so earlier offsets stay valid after each splice.
    # In-place reverse beats Sort-Object for the typical 1-command line.
    if ($commands.Count -gt 1) {
        $commands = [System.Collections.Generic.List[object]]::new($commands)
        $commands.Reverse()
    }

    foreach ($cmd in $commands) {
        $name = $cmd.GetCommandName()
        if (!$name) {
            continue
        }

        $baseName = $name
        if ($name.EndsWith('.exe') -or $name.EndsWith('.cmd')) {
            $baseName = $name.Substring(0, $name.Length - 4)
        }
        if (!$script:__COREUTILS__.Contains($baseName)) {
            continue
        }

        # ls/la get colour + listing flags injected; la also rewrites to ls.
        $cmdElement = $cmd.CommandElements[0]
        $start = $cmdElement.Extent.StartOffset
        $end = $cmdElement.Extent.EndOffset
        $replacement = "& 'C:\Program Files\coreutils\cmd\"

        switch ($baseName) {
            'la' { $replacement += "ls.cmd' --color=auto -AFhl" }
            'ls' { $replacement += "ls.cmd' --color=auto" }
            default { $replacement += "$baseName.cmd'" }
        }

        # Walk command elements, merging adjacent ones whose extents touch
        # (e.g. `'a'*` parses as [SingleQuoted, BareWord] but is one shell word).
        # The inverse case `*'a'*` parses as a single BareWord whose text
        # contains the embedded quotes, which is why AST-only analysis
        # isn't enough and we still need to re-tokenize the source span.
        $argsStart = $end
        $argsEnd = $cmd.Extent.EndOffset
        $rewrittenArgs = ''
        $elements = $cmd.CommandElements
        $count = $elements.Count
        $i = 1
        while ($i -lt $count) {
            $first = $elements[$i]
            $wordStart = $first.Extent.StartOffset
            $wordEnd = $first.Extent.EndOffset
            $merged = $false
            while ($i + 1 -lt $count -and $elements[$i + 1].Extent.StartOffset -eq $wordEnd) {
                $i++
                $wordEnd = $elements[$i].Extent.EndOffset
                $merged = $true
            }
            $source = $line.Substring($wordStart, $wordEnd - $wordStart)
            $rewrittenArgs += $line.Substring($argsStart, $wordStart - $argsStart)
            $argsStart = $wordEnd
            # IndexOfAny beats running the regex per arg.
            if ($source.IndexOfAny($script:__COREUTILS_ARG_SPECIAL__) -lt 0) {
                $rewrittenArgs += $source
                $i++
                continue
            }
            # A single un-merged PS expression that needs $var resolution
            # (bare $var, "...$var...", $x.Member, $($expr), etc.).
            # Defer evaluation to runtime so the value reaches coreutils as a literal arg.
            # This matches POSIX behaviour where variable expansions don't result in globbing.
            if (-not $merged -and
                ($first -is [System.Management.Automation.Language.VariableExpressionAst] -or
                $first -is [System.Management.Automation.Language.ExpandableStringExpressionAst] -or
                $first -is [System.Management.Automation.Language.MemberExpressionAst])) {
                $rewrittenArgs += '(__coreutils_q ' + $source + ')'
                $i++
                continue
            }
            # Slow path: re-tokenise and re-emit as MSVCRT-style quoting,
            # then wrap in PS single quotes so PS hands the body verbatim.
            $windowsQuoted = $script:__COREUTILS_ARG_RX__.Replace($source, $script:__COREUTILS_ARG_EVAL__)
            $rewrittenArgs += "'" + $windowsQuoted.Replace("'", "''") + "'"
            $i++
        }
        $rewrittenArgs += $line.Substring($argsStart, $argsEnd - $argsStart)

        $line = $line.Substring(0, $start) + $replacement + $rewrittenArgs + $line.Substring($argsEnd)
    }

    return $line
}
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# DO NOT MODIFY -- coreutils -- 60b36fc6-2d59-49df-be51-28dd2f4c3c9a
