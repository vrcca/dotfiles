#!/usr/bin/env bash

# Absolute path this script is in, thus /home/user/bin
EMACS_PATH=$HOME/.emacs.d
FISHBIN_PATH="/usr/local/bin/fish"
CONFIG_PATH="$HOME/.config"
FISHCONFIG_PATH="$CONFIG_PATH/fish"
FISHER_PATH="$FISHCONFIG_PATH/functions/fisher.fish"

# Homebrew
echo "Setting up Homebrew"
command -v brew >/dev/null 2>&1 || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
echo "done."
echo "Installing dependencies..."
brew bundle
echo "done."

# Emacs
mkdir -p $CONFIG_PATH/doom
ln -s config/doom/config.el $CONFIG_PATH/doom/config.el
ln -s config/doom/init.el $CONFIG_PATH/doom/init.el
ln -s config/doom/packages.el $CONFIG_PATH/doom/packages.el
ln -s config/doom/custom.el $CONFIG_PATH/doom/custom.el
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
$EMACS_PATH/bin/doom install --no-config

echo "Setting up Fish..."
if [[ $SHELL != $FISHBIN_PATH ]]; then
    sudo -v
    echo "Changing default shell to $FISHBIN_PATH"
    sudo bash -c "cat /etc/shells | grep -Fxq $FISHBIN_PATH || echo $FISHBIN_PATH >> /etc/shells"
    chsh -s $FISHBIN_PATH
    echo "done."
fi

# Fish shell
echo "Installing Fish dependencies..."
mkdir -p $HOME/.config/fish/
echo $BASEDIR
ln -Ffs `pwd`/fishshell/fish_plugins $HOME/.config/fish/fish_plugins
echo "Copied fish_plugins."
ln -Ffs `pwd`/fishshell/config.fish $HOME/.config/fish/config.fish
if [[ ! -f $FISHER_PATH ]]; then
    curl https://git.io/fisher --create-dirs -sLo $FISHER_PATH
fi
cp -vr fishshell/functions/* $FISHCONFIG_PATH/functions
fish -c "fisher update"
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
fish -c "set -xU KERL_CONFIGURE_OPTIONS \"--disable-debug --without-javac\""
echo "done."

# Git defaults
cp .gitignore $HOME/.gitignore

# MacOS default settings
echo "Setting up MacOS defaults"
# opens finder at home
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder QuitMenuItem -bool true
# sets date format
defaults write ~/Library/Preferences/com.apple.menuextra.clock.plist DateFormat -string "EEE d MMM HH:mm:ss"
# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disables media keys (use Fn instead)
defaults write NSGlobalDomain "com.apple.keyboard.fnState" -int 1
# Enables three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 1
# minimizes app to its own icon in dock
defaults write com.apple.dock minimize-to-application -bool true
# uses scale animation when minimizing app
#defaults write com.apple.dock mineffect
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0
# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Finder: Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Sound: feedback on volume change
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -bool true
# Battery: displays percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
# Sets menu items in the menubar to be: Clock, Battery, AirPort, Displays, Bluetooth, then Volume.
cp com.apple.systemuiserver.plist $HOME/Library/Preferences/com.apple.systemuiserver.plist 

#restarts everything
killall SystemUIServer
killall Finder
echo "done."

echo "Please, restart computer."
