# Absolute path this script is in, thus /home/user/bin
EMACS_PATH=$HOME/.emacs.d
FISHBIN_PATH="/usr/local/bin/fish"
FISHCONFIG_PATH="$HOME/.config/fish"
FISHER_PATH="$FISHCONFIG_PATH/functions/fisher.fish"

# Homebrew
echo "Setting up Homebrew"
command -v brew >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "done."
echo "Installing dependencies..."
brew bundle
echo "done."

# Emacs
if [ ! -d $EMACS_PATH/.git ]; then
    echo "Setting up Emacs..."
    rm -rf $EMACS_PATH
    git clone https://github.com/vrcca/emacs-configuration.git $EMACS_PATH
    echo "done."
fi

echo "Setting up Fish..."
if [[ $SHELL != $FISHBIN_PATH ]]; then
    echo "Changing default shell to $FISHBIN_PATH"
    sudo bash -c "cat /etc/shells | grep -Fxq $FISHBIN_PATH || echo $FISHBIN_PATH >> /etc/shells"
    chsh -s $FISHBIN_PATH
    echo "done."
fi

# Fish shell
echo "Installing Fish dependencies..."
mkdir -p $HOME/.config/fish/
echo $BASEDIR
ln -Ffs `pwd`/fishshell/fishfile $HOME/.config/fish/fishfile
echo "Copied fishfile."
if [[ ! -f $FISHER_PATH ]]; then
    curl https://git.io/fisher --create-dirs -sLo $FISHER_PATH
fi
cp -vr fishshell/functions/* $FISHCONFIG_PATH/functions
fish -c fisher
echo "done."

# Editors
echo "Setting editors to emacs"
fish -c "set -U VISUAL emacs"
fish -c "set -U EDITOR emacs"
git config --global core.editor "emacs -nw"
echo "done."

# Default directories
echo "Creating directory structure"
mkdir -p $HOME/Developer/vrcca
echo "done."

# iTerm2
cp -v iterm2_profile.plist $HOME/Library/Preferences/com.googlecode.iterm2.plist

# ASDF plugins
echo "Adding ASDF plugins..."
asdf plugin-add elixir
asdf plugin-add erlang
asdf plugin-add java
asdf install java oracle-8.191
asdf global java oracle-8.191
fish -c "set -xU KERL_CONFIGURE_OPTIONS \"--disable-debug --without-javac\""
echo "done."


# MacOS default settings
echo "Setting up MacOS defaults"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
echo "done."

echo "Please, restart terminal."
