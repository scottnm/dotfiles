param(
    [Parameter(Mandatory)]
    [string]$Path
    )

gpg -d $Path
