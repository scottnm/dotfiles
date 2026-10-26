
function Apply-ExeFirewall
{
<#
.SYNOPSIS
    Adds (or removes) Windows Firewall rules that block ALL network traffic for
    the compiled mermaid_to_visio.exe.

.DESCRIPTION
    Creates two block rules — one Outbound and one Inbound — for the executable,
    covering all protocols and all firewall profiles (Domain/Private/Public).
    Block rules take precedence over allow rules in Windows Firewall, so this
    guarantees the program cannot send or receive network traffic.

    Must be run from an ELEVATED (Administrator) PowerShell session.

.PARAMETER ExePath
    Full path to the executable to block.

.PARAMETER Remove
    Remove the previously created rules instead of adding them.

.EXAMPLE
    # Apply the block rules (run as Administrator)
    Apply-ExeFirewall

.EXAMPLE
    # Block a custom path
    Apply-ExeFirewall -ExePath "C:\Tools\mermaid_to_visio.exe"

.EXAMPLE
    # Remove the rules
    Apply-ExeFirewall -Remove
#>

    [CmdletBinding()]
    param(
        [string]$ExePath,
        [switch]$Remove
    )

    $ErrorActionPreference = 'Stop'

    $exeBaseName = (Get-Item $ExePath).BaseName
    $ruleGroup = "$exeBaseName block"
    $outName   = "Block $exeBaseName OUT"
    $inName    = "Block $exeBaseName IN"

    # Ensure we are running elevated; firewall changes require admin rights.
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        throw 'This script must be run from an elevated (Administrator) PowerShell session.'
    }

    if ($Remove) {
        Write-Host "==> Removing firewall rules in group '$ruleGroup'..." -ForegroundColor Cyan
        $existing = Get-NetFirewallRule -Group $ruleGroup -ErrorAction SilentlyContinue
        if ($existing) {
            $existing | Remove-NetFirewallRule
            Write-Host '==> Rules removed.' -ForegroundColor Green
        } else {
            Write-Host '==> No matching rules found.' -ForegroundColor Yellow
        }
        return
    }

    # Resolve to a literal full path — Windows Firewall matches on the on-disk path.
    if (-not (Test-Path -LiteralPath $ExePath)) {
        throw "Executable not found: $ExePath. Build it first with .\build_native.ps1"
    }
    $ExePath = (Resolve-Path -LiteralPath $ExePath).Path

    # Remove any stale rules from a previous run so we don't create duplicates.
    Get-NetFirewallRule -Group $ruleGroup -ErrorAction SilentlyContinue | Remove-NetFirewallRule

    Write-Host "==> Blocking all network traffic for: $ExePath" -ForegroundColor Cyan

    New-NetFirewallRule -DisplayName $outName -Group $ruleGroup `
        -Description 'Block all outbound traffic for mermaid_to_visio.exe' `
        -Direction Outbound -Program $ExePath -Action Block `
        -Profile Any -Protocol Any -Enabled True | Out-Null

    New-NetFirewallRule -DisplayName $inName -Group $ruleGroup `
        -Description 'Block all inbound traffic for mermaid_to_visio.exe' `
        -Direction Inbound -Program $ExePath -Action Block `
        -Profile Any -Protocol Any -Enabled True | Out-Null

    Write-Host '==> Firewall rules created:' -ForegroundColor Green
    Get-NetFirewallRule -Group $ruleGroup |
        Format-Table DisplayName, Direction, Action, Enabled -AutoSize

    Write-Host ''
    Write-Host "To remove later: $($PSCmdlet.MyInvocation.MyCommand.Name) -Remove" -ForegroundColor DarkGray
}