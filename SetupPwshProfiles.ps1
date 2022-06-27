& .\paths.ps1

mkdir -Force $env:WindowsPSPath
mkdir -Force $env:WindowsPSCorePath
rm -Force $env:WindowsPSProfilePath
rm -Force $env:WindowsPSCoreProfilePath
rm -Force $env:WindowsPSSideProfilePath
cmd /c mklink $env:WindowsPSProfilePath $env:PSProfilePath
cmd /c mklink $env:WindowsPSCoreProfilePath $env:PSProfilePath
cmd /c mklink $env:WindowsPSSideProfilePath $env:PSSideProfilePath
