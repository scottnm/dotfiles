& $PSScriptRoot\paths.ps1

# powershell profile paths
rm $env:WindowsPSProfilePath

# Vim paths
rm $env:WindowsVimConfPath
rm -rec -force $env:WindowsVimAfterPath

# GHCI
rm $env:WindowsGhciConfPath
