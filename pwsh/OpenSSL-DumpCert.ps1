param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
    )

openssl x509 -in $FilePath -noout -text