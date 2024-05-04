### Installation

```
cd ~
git clone --bare git@github.com:ignaciocuello/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout
config config push.autoSetupRemote true
```

Remove any existing files if `config checkout` fails, then try again.

Source: [Atlassian](https://www.atlassian.com/git/tutorials/dotfiles)
