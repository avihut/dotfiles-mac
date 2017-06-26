# Avihu's dot file Configrations
## Prerequisites
- OS: macOS
- Shell: `zsh`
- Vim package manager: [`Vim-Plug`](https://github.com/junegunn/vim-plug)

## Setup

1. Clone the repository to a configuration directory called `.cfg` under youe home directory
```shell
git clone --bare git@github.com:avihubuga/Ubuntu-Dot-File-Configuration.git ~/.cfg
```

2. Checkut the configuration
```shell
git --git-dir="$HOME/.cfg" --work-tree="$HOME" checkout -f --
```

3. Apply configuration changes
```shell
source ~/.zshrc
```
4. `alias` the configuration command (done automatically in [`.zshrc`](.zshrc#L89))
```
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
