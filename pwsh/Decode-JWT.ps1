Param(
[Parameter(Mandatory = $true)]$JwtString
)

$JwtParts = $JwtString -split '\.'
$JwtParts = $JwtParts | %{ Decode-Base64.ps1 -Base64String $_ }

$JwtParts