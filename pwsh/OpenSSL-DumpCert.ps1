[CmdletBinding(DefaultParameterSetName = 'File')]
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'File')]
    [string]$FilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'BarePem')]
    [string]$BarePemString
)

if ($PSCmdlet.ParameterSetName -eq 'BarePem') {
    $pem = "-----BEGIN CERTIFICATE-----`n$BarePemString`n-----END CERTIFICATE-----"
    $pem | openssl x509 -noout -text
}
else {
    openssl x509 -in $FilePath -noout -text
}