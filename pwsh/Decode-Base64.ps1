Param(
[Parameter(Mandatory = $true)]$Base64String
)

$tmpInputFile = New-TemporaryFile
try
{
    $tmpOutputFile = (Join-Path $env:TEMP "$(new-guid)-b64.bin.tmp")
    try
    {
        Set-Content -Path $tmpInputFile -Value $Base64String -NoNewLine
        $certUtilOutput = certutil -decode $tmpInputFile $tmpOutputFile
        if ($LASTEXITCODE -ne 0) {
            throw "Failed decode! $certUtilOutput"
        }

        Get-Content $tmpOutputFile -Raw
    }
    finally {
        Remove-Item -Path $tmpOutputFile -Force
    }
}
finally {
    Remove-Item -Path $tmpInputFile -Force
}
