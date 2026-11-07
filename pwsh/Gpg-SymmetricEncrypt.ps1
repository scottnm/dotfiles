param(
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$CipherAlgo = "AES256"
    )

gpg --symmetric --cipher-algo $CipherAlgo $Path
