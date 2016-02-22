alias reshell=". ~/.zshrc"

export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "

export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gitfast git-extras)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/git/bin:/usr/texbin:/usr/local/go/bin/"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# THE REAL BANANAS

# shell commands
alias clear="clear && clear && clear && clear && clear"
alias make="sh ~/colormake.sh"
alias lss='ls -laGFh'

# shell navigation
alias godev='cd ~/Development/'
alias gogov='cd ~/Documents/8\ -\ Spring\ 2016/GOV312L'
alias gormotr='cd ~/Development/rmotr'
alias gohome='cd ~'
alias godesk='cd ~/Desktop'

# git shortcuts
alias gstat='git status'
unalias gsta
alias gua='git add -u'
alias gcm="git commit -m"
alias gmv="git mv"
alias gtree="git log --graph --oneline --all"

# color less
export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

# CTRL-b d to detach a tmux session
alias tmuxrestore="tmux a #0"

# Hub auto completions
fpath=(~/.zsh/completions $fpath) 
autoload -U compinit && compinit

# Python
alias pyclean="find . | grep -E '(__pycache__|\.pyc|\.pyo$)' | xargs rm -rf"
alias pyenv=". venv/bin/activate"
alias newpyenv="virtualenv venv"
alias pyignore="echo '*.swp\n*.pyc\n__pycache__\ntmp*\nvenv\n' > .gitignore"

# Lua
alias love="/Applications/love.app/Contents/MacOS/love"

# GOV312L
alias GOV312L_R="sh ~/Documents/8\ -\ Spring\ 2016/GOV312L/gov312L_reading.sh"

# CS105 PHPSQL
alias gophp="ssh -t scottnm@linux.cs.utexas.edu 'cd /u/z/users/cs105/scottnm ; zsh'"

# SSHing
alias sshmb="ssh scottmunro@192.168.0.15"
alias sshdesk="ssh scottmunro@192.168.0.20"
alias sshlab="ssh scottnm@linux.cs.utexas.edu"

# Lab specific
alias chkquota="chkquota && du -a ~/ | sort -n -r | head -n 10"
alias gogame="cd ~/Documents/CS354R/A2/appdirectory"
alias ogreclean="make clean; rm -rf .deps Makefile Makefile.in Ogre.log aclocal.m4 autom4te.cache compile config.guess config.h config.h.in config.log config.status config.sub configure depcomp install-sh libtool ltmain.sh m4 missing ogre.cfg stamp-h1"

# Desktop specific

# Laptop specific
alias findremove="echo 'perl -pi -w -e 's/PATTERN/REPLACE/g;' FILE'"
export PATH=$PATH:/Library/TeX/Distributions/.DefaultTeX/Contents/Programs/texbin

# Archiving
alias tarchive="tar -cvzf"
alias untarchive="tar -xvzf"
