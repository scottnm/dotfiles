param(
    [Parameter(Mandatory)]
    [string]$Path,
    [string]$OutputPath,
    [string]$CipherAlgo = "AES256"
    )

$outputArgs = @()
if ($OutputPath)
{
    $outputArgs += @("-o", $OutputPath)
}
gpg @outputArgs --symmetric --cipher-algo $CipherAlgo $Path
