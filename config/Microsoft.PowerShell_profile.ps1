Set-PSReadlineOption -BellStyle None
New-Alias -Name grep -Value select-string -Force -Option AllScope

function Update-PShell { & . $PROFILE }
New-Alias -Name upshell -Value Update-PShell -Force -Option AllScope
function Go-Src { & cd z:\os\src }
New-Alias -Name gosrc -Value Go-Src -Force -Option AllScope
function Get-GitDiff { & git diff $args }
New-Alias -Name gd -Value Get-GitDiff -Force -Option AllScope
function Get-GitStatus { & git status -sb $args }
New-Alias -Name gst -Value Get-GitStatus -Force -Option AllScope
function Get-GitCommit { & git commit $args }
New-Alias -Name gc -Value Get-GitCommit -Force -Option AllScope
function Get-GitAdd { & git add --all $args }
New-Alias -Name ga -Value Get-GitAdd -Force -Option AllScope
function Get-GitPush { & git push $args }
New-Alias -Name gp -Value Get-GitPush -Force -Option AllScope
function Get-GitPull { & git pull $args }
New-Alias -Name gl -Value Get-GitPull -Force -Option AllScope
function Get-GitCheckout { & git checkout $args }
New-Alias -Name gco -Value Get-GitCheckout -Force -Option AllScope

function prompt {
	$host.ui.rawui.WindowTitle = $(get-location)

	Write-Host("")

	$status_string = " $(get-location) "

	if(Test-Path .git) {
        $status_string += "::"
		git branch | foreach {
			if ($_ -match "^\*(.*)"){
				$status_string += $matches[1]
			}
		}
	}

    $status_string += "
    > "

	Write-Host ($status_string) -nonewline -foregroundcolor yellow
	return " "
}