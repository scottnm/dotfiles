$checkUserName = (git config user.name)
if (!$checkUserName)
{
    $username = Read-Host -Prompt "Git name? "
    git config --global user.name $username
}

$checkUserMail = (git config user.email)
if (!$checkUserMail)
{
    $mail = Read-Host -Prompt "Git email? "
    git config --global user.email $mail
}

# Setup git config
# git config --global core.editor "C:/Windows/gvim.bat"
git config --global core.editor "vim"
git config --global push.default current

