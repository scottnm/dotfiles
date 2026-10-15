Param(
[Parameter(Mandatory = $true)]$Base64String
)

$tmpInputFile = New-TemporaryFile
try
{
    $tmpOutputFile = New-TemporaryFile
    try
    {
        Set-Content -Path $tmpInputFile -Value $Base64String -NoNewLine
        certutil -decode $tmpInputFile $tmpOutputFile
        Get-Content $tmpOutputFile -Raw
    }
    finally {
        Remove-Item -Path $tmpOutputFile -Force
    }
}
finally {
    Remove-Item -Path $tmpInputFile -Force
}
