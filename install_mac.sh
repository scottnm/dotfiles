#!/bin/sh

# to download this remotely use...
# wget https://raw.githubusercontent.com/scottnm/dotfiles/master/install_mac.sh -O ~/Downloads/install_mac.sh && chmod +x ~/Downloads/install_mac.sh

set -e

path_contains() {
    if [[ ":$PATH:" == *":$1:"* ]]; then
        true
        return
    else
        false
        return
    fi
}

command_exists() {
    command_name=$1
    if command -v $command_name 2>&1 >/dev/null
    then
        true
        return
    else
        false
        return
    fi
}

brew_install_if_missing() {
    package_name=$1
    package_command_name=$2
    package_repr="$package_name ($package_command_name)"
    if [ -z "$package_command_name" ]; then
        package_command_name=$package_name
        package_repr="$package_name"
    fi

    if command_exists "$package_command_name"; then
        echo "$package_repr already installed"
    else
        echo "installing $package_repr"
        brew install $package_name
    fi
}

#
# Main tools
#
echo "Installing main tools..."
if command_exists "brew"; then
    echo "brew already installed"
elif command_exists "/opt/homebrew/bin/brew"; then
    echo "brew already installed"
else
    echo "installing brew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if path_contains "/opt/homebrew/bin"; then
    echo "brew already in path"
else
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/scottmunro/.zshrc
    export PATH=$PATH:/opt/homebrew/bin/
    echo "added brew to path"
fi

brew_install_if_missing "git"
brew_install_if_missing "neovim"
brew_install_if_missing "curl"

#
# Setup dev and dotfiles
#
echo "setting up dotfiles..."
mkdir -p "$HOME/dev"
DOTFILES="$HOME/dev/dotfiles"
if [ -d "$DOTFILES" ]; then
    echo "dotfiles already exists"
else
    git clone https://github.com/scottnm/dotfiles $DOTFILES
fi

#
# Setting up unix environment
#
# make sure that my .profile is set
echo "setting up unix profiles..."
UNIX_PROFILE="$HOME/.profile"
rm -f $UNIX_PROFILE
ln -s "$DOTFILES/config/unix_profile" $UNIX_PROFILE
echo "    ...set unix .profile!"

echo "linking inputrc..."
INPUT_RC="$HOME/.inputrc"
rm -f $INPUT_RC
ln -s "$DOTFILES/config/.inputrc" $INPUT_RC
echo "    ...inputrc linked"

# echo "linking powershell profile..."
# POWERSHELL_PROFILE="$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
# rm -f $POWERSHELL_PROFILE
# ln -s "$DOTFILES/config/ps_main.ps1" $POWERSHELL_PROFILE
# echo "    ...powershell profile linked"

#
# Setup VIM config
#
echo "setting up vim config"
echo ""
echo "linking vimrc..."
VIM_CONFIG="$HOME/.vimrc"
rm -f $VIM_CONFIG
ln -s "$DOTFILES/config/_vimrc" $VIM_CONFIG
echo "...vimrc linked"

echo "linking gvimrc..."
GVIM_CONFIG="$HOME/.gvimrc"
rm -f $GVIM_CONFIG
ln -s "$DOTFILES/config/.gvimrc" $GVIM_CONFIG
echo "...gvimrc linked"

echo "setting up nvim config..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p $NVIM_CONFIG_DIR

echo "   linking nvim init.vim..."
NVIM_CONFIG="$NVIM_CONFIG_DIR/init.vim"
rm -f $NVIM_CONFIG
ln -s "$DOTFILES/config/nvim_init.vim" $NVIM_CONFIG
echo "    ...nvim init.vim linked"

echo "   linking nvim ginit.vim..."
NVIM_GCONFIG="$NVIM_CONFIG_DIR/ginit.vim"
rm -f $NVIM_GCONFIG
ln -s "$DOTFILES/config/nvim_ginit.vim" $NVIM_GCONFIG
echo "    ...nvim ginit.vim linked"

echo "...nvim config setup"

echo "Installing extra tools..."
brew_install_if_missing "visual-studio-code" "code"
brew_install_if_missing "iterm2"