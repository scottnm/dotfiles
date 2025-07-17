######################################
#### WARNINGS FOR NEEDED ENV VARS ####
######################################
function VerifyEnvironmentVariable
{
    Param(
        [string]$Name,
        [string]$EnvSkipKey
        )

    if (! (Get-Item -path "Env:$Name" -ErrorAction SilentlyContinue) )
    {
        if ($EnvSkipKey)
        {
            if (! (Get-Item -path "Env:$EnvSkipKey" -ErrorAction SilentlyContinue) )
            {
                Write-Error "`$env:$Name not set and `$env:$EnvSkipKey not found! Set in system path variables"
            }
        }
        else
        {
            Write-Error "`$env:$Name not set! Set in system path variables"
        }
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

# DevEnv edit paths
function Edit-Profile { dvim $profile $env:SideProfilePath }
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
    $path = Join-Path -path $env:TopicNotesDir -ChildPath "${env:GitTopic}_notes.md"
    dvim $path
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
        $branchPrompt = Colored -Text $env:GitBranch -Color Green
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
    $prompt = (Colored -Text "λ " -Color Yellow)
    return $prompt
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
    git pull -q

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
function grep { param([string]$filesPattern,[string]$pattern) sls -path $filesPattern -pattern $pattern }

function edit-hosts { Start-Process -FilePath vim -ArgumentList c:\windows\system32\drivers\etc\hosts -Verb RunAs }
function type-hosts { type c:\windows\system32\drivers\etc\hosts | sls "^\w" -NoEmphasis }

# net stop beep

function Set-WinHttpProxy
{
    write-host -foregroundcolor darkgray 'netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"'
    netsh winhttp set proxy 127.0.0.1:8888 "<-loopback>"
}
function Clear-WinHttpProxy
{
    write-host -foregroundcolor darkgray 'netsh winhttp reset proxy'
    netsh winhttp reset proxy
}

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
            dvim $journalPath -c "call NewJournalEntry()"
        }
        else
        {
            dvim $journalPath
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

    if ($NameOnly)
    {
        git diff --name-only "$Start..$End" | %{ git grep --name-only $CaseSensitiveOption $Pattern -- $_ }
    }
    else
    {

        git diff --name-only "$Start..$End" |
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

function OpensslPem2Der {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$OutPath
    )

    openssl x509 -inform PEM -in $FilePath -outform DER -out $OutPath -text
}

function OpensslDumpCert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    openssl x509 -in $FilePath -noout -text
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

new-alias Launch-AndroidEmulator $env:ANDROID_SDK_ROOT\emulator\emulator.exe -Force -Option AllScope

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
