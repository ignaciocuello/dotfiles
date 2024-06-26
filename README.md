### Installation

```
cd ~
git clone --bare git@github.com:ignaciocuello/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
config config --local status.showUntrackedFiles no
config config push.autoSetupRemote true
### If copying to your personal mac
cp ~/.zshrc.macos.personal ~/.zshrc

brew bundle --no-lock

# Install nerd fonts
brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true

# Install vim key bindings for the terminal
git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode

# Set your git user
git config --global user.email "your@email.com"
git config --global user.name "Ignacio Cuello"
```

Remove any existing files if `config checkout` fails, then try again.

Sources: 
- [Atlassian](https://www.atlassian.com/git/tutorials/dotfiles)
- [Nerd Fonts for your IDE](https://gist.github.com/davidteren/898f2dcccd42d9f8680ec69a3a5d350e)
