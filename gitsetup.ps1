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
git config --global core.editor "C:/tools/vim/vim82/gvim.exe"
git config --global push.default current
# each repo requires its own credentials (enable multiple credentials one machine)
git config --global credential.github.com.useHttpPath true
