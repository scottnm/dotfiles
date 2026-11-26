[cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]$SlnPath,
    [string]$ProjectPath,
    [ValidateSet("Debug", "Release")]
    [string[]]$Configurations = @("Debug", "Release"),
    [ValidateSet("quiet", "minimal", "normal", "detailed", "diagnostic")]
    [string]$Verbosity = "minimal",
    [string]$Platform="x64",
    [ValidateSet("Build", "Clean", "Rebuild", "Restore", "Publish")]
    [string[]]$BuildTargets = @("Restore", "Build"),
    [int]$NumCores = 0
    )

$SlnPath = Resolve-Path $SlnPath
$projectToBuild = if ($ProjectPath) { Resolve-Path $ProjectPath } else { $SlnPath }

$msbuildPath = $env:VsMSBuildPath
if (-not $msbuildPath)
{
    throw "Must set `$env:VsMSBuildPath"
}
if (!$numCores)
{
    $numCores = [Environment]::ProcessorCount
}

$BuildTargetsArgs = New-Object System.Collections.ArrayList
$hasRestore = $BuildTargets.Contains("Restore")
foreach ($buildTarget in $BuildTargets)
{
    if ($buildTarget -ne "Restore")
    {
        $BuildTargetsArgs.Add($buildTarget) | Out-Null
    }
}

foreach ($config in $Configurations)
{
    Write-Host -foregroundcolor cyan "Building $((Get-Item $slnPath).Name) ($config : $platform)"

    $msbuildArgs = New-Object System.Collections.ArrayList
    $msbuildArgs.Add($projectToBuild) | Out-Null
    if ($ProjectPath)
    {
        $SolutionDir = (Get-Item $SlnPath).Directory
        $msbuildArgs.Add("-p:SolutionDir=$SolutionDir") | Out-Null
    }
    if ($hasRestore)
    {
        $msbuildArgs.Add("-p:RestorePackagesConfig=true") | Out-Null
        $msbuildArgs.Add("/restore") | Out-Null
    }
    $msbuildArgs.Add("-verbosity:$Verbosity") | Out-Null
    $msbuildArgs.Add("-p:Configuration=$config") | Out-Null
    $msbuildArgs.Add("-p:Platform=$platform") | Out-Null
    $msbuildArgs.Add("-m:$numCores") | Out-Null
    if ($Verbosity -in ("minimal", "quiet"))
    {
        $msbuildArgs.Add("-tl:auto") | Out-Null
    }
    if ($BuildTargetsArgs.Count -gt 0)
    {
        $BuildTargetsArgString = "-t:" + ($BuildTargetsArgs -join ",")
        $msbuildArgs.Add($BuildTargetsArgString) | Out-Null
    }

    Write-Host -foregroundcolor darkgray "& $msbuildPath $msbuildArgs"
    & $msbuildPath @msbuildArgs

    if (!$?)
    {
        throw "Failed building $((Get-Item $slnPath).Name) ($config : $platform)"
    }
}
