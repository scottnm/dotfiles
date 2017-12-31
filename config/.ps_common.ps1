###############
# GIT ALIASES #
###############
function gst
{
    $status = & git status $args

    if (!$status)
    {
        $env:current_git_repo = "not a git repo"
        return $status
    }
    $env:current_git_repo = $status.split()[2]
    $localend=$env:current_git_repo.IndexOf('.')
    if ($localend -ne -1)
    {
        $env:current_git_repo = $env:current_git_repo.Substring(0,$localend)
    }
    return $status
}
function update-current-git-repo { $_=gst }
function gc { & git commit -ev $args }
function ga { & git add --all $args }
function gp { & git push $args }
function gl { & git pull $args }
function gco { & git checkout $args; & update-current-git-repo }
function gue { & git checkout -- $args }

########
# MISC #
########
new-alias pd pushd -Force -Option AllScope
function grep($files, $pattern) { dir -recurse $files | select-string $pattern }
function gohosts { & pushd c:\windows\system32\drivers\etc }
& update-current-git-repo
