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
