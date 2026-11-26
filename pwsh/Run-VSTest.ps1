[cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]$DllPath
    )

$DllPath = Resolve-Path $DllPath

$vsTestPath = $env:VsTestConsoleExePath
if (-not $msbuildPath)
{
    throw "Must set `$env:VsTestConsoleExePath"
}

$testArgs = @($DllPath)

Write-Host -foregroundcolor darkgray "& $vsTestPath $testArgs"
& $vsTestPath @testArgs

if (!$?)
{
    throw "Failed running tests $((Get-Item $DllPath).Name)"
}
