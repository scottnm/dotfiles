param([switch]$Undo)

function DoCmd {
    write-host -foreground darkgray "$args"
    $cmd = $args[0]
    $otherArgs = ($args | select -skip 1)
    & $cmd @otherArgs
}

if ($Undo)
{
    DoCmd reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
    write-host -foregroundcolor green "Modern context menu set"
}
else
{
    DoCmd reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
    write-host -foregroundcolor green "Legacy context menu set"
}
