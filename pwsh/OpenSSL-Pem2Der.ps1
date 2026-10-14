param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath,
    [Parameter(Mandatory=$true)]
    [string]$OutPath
)

openssl x509 -inform PEM -in $FilePath -outform DER -out $OutPath -text