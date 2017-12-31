mkdir ~\Documents\WindowsPowerShell
cmd /c mklink ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 ~\Dev\dotfiles\config\Microsoft.PowerShell_profile.ps1
cmd /c mklink ~\_vimrc ~\Dev\dotfiles\config\_vimrc
git config --global core.editor "vim"
