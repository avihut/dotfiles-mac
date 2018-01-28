# Avihu's dot file Configrations
## Prerequisites
- OS: macOS
- Shell: `zsh`
- Vim package manager: [`Vim-Plug`](https://github.com/junegunn/vim-plug)

## Setup

1. Download and install [Meslo Powerline Font](https://github.com/powerline/fonts/blob/master/Meslo%20Slashed/Meslo%20LG%20M%20Regular%20for%20Powerline.ttf).

2. Clone the repository to a configuration directory called `.cfg` under youe home directory
```shell
git clone --bare git@github.com:avihut/Mac-Dot-File-Configuration.git ~/.cfg
```

3. Checkut the configuration
```shell
git --git-dir="$HOME/.cfg" --work-tree="$HOME" checkout -f --
```

4. Apply configuration changes
```shell
source ~/.zshrc
```
5. `alias` the configuration command (done automatically in [`.zshrc`](.zshrc#L89))
```
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
