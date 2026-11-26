param(
    [Parameter(Mandatory)]
    [string]$Source,
    [string]$Destination,
    [switch]$NoCompress,
    [switch]$Purge,
    [int]$MinFileSizeBytes,
    [int]$MaxFileSizeBytes,
    [string[]]$ExcludeDirectories,
    [switch]$WhatIf
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

if ($ExcludeDirectories)
{
    $args.Add("/XD")
    foreach ($ed in $ExcludeDirectories)
    {
        $args.Add("$ed")
    }
}

if ($WhatIf)
{
    $args.Add("/L")
}

write-host -foregroundcolor darkgray "robocopy $args"
robocopy @args
