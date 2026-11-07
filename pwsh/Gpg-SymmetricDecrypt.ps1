param(
    [Parameter(Mandatory)]
    [string]$Path,
    [string]$OutputPath
    )

$outputArgs = @()
if ($OutputPath)
{
    $outputArgs += @("-o", $OutputPath)
}
gpg @outputArgs -d $Path
