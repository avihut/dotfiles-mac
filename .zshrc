# If you come from bash you might have to change your $PATH.
export HOME_BIN=$HOME/bin
export LOCAL_BIN=/usr/local/bin
export BOOST_ROOT=/usr/local/lib/boost/boost_1_64_0
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_TOOLS=$ANDROID_HOME/tools
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools
export HOME_LIB="$HOME/lib"
export FLUTTER_LIB="$HOME_LIB/flutter"
export FLUTTER_BIN="$FLUTTER_LIB/bin"
export LIBEXEC=/usr/libexec
export PROJECT_HOME=$HOME/Projects
export HYDRA_HOME=$PROJECT_HOME/Hydra/bin
export PATH=$LIBEXEC:$FLUTTER_BIN:$BOOST_ROOT:$HOME_BIN:$LOCAL_BIN:$ANDROID_TOOLS:$ANDROID_PLATFORM_TOOLS:$HYDRA_HOME:$PATH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(rbenv init -)"

eval "$(pyenv init -)"
eval "pyenv virtualenvwrapper"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context virtualenv dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
POWERLEVEL9K_RBENV_BACKGROUND='red'
POWERLEVEL9K_RBENV_FOREGROUND='white'
POWERLEVEL9K_PYENV_BACKGROUND='yellow'
POWERLEVEL9K_PYENV_FOREGROUND='black'
POWERLEVEL9K_VIRTUALENV_BACKGROUND='magenta'
POWERLEVEL9K_VIRTUALENV_FOREGROUND='white'

ENABLE_CORRECTION="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	# For some reason syntax highlighting works even though
	# this plugin is turned off.
	zsh-syntax-highlighting
	zsh-autosuggestions
	colorize
	extract
)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

alias config='/usr/local/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias g='googler -n 7 -l en'

alias cdflutter='cd $FLUTTER_LIB'

alias venv='python -m venv'

alias n='nocorrect'

# git shortcuts
alias gdst='gd --staged'
alias gcvm='git commit -v -m'
alias gadc='git add -u'
alias gadu='git add $(git ls-files -o --exclude-standard)'
alias glop='git log --oneline --patch'
alias gc-b='git checkout -b'
alias pipup="python3 -m pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U"
alias brewup='brew upgrade && brew cleanup && brew cleanup --prune-prefix'
alias ggroom='git remote prune origin && git gc --prune=now'
alias gbranches='nocorrect git branch -r | grep -v HEAD | while read b; do git log --color --format="%ci _%C(magenta)%>(15)%cr %C(bold blue)%<(16)%an%Creset %C(bold cyan)$b%Creset %s" $b | head -n 1; done | sort -r | cut -d_ -f2- | sed "s;origin/;;g"'
alias gprune='nocorrect git branch -r | awk "{print $1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print $1}" | xargs git branch -d'

# Taken from https://superuser.com/questions/168749/is-there-a-way-to-see-any-tar-progress-per-file
targz() {
	if [ "$#" -eq 0 ]; then
		echo "Usage: targz <path to tar> [archive name]"
		echo "   If archive name is not provided, it will be based on the name of the path being archived."
		return 1
	fi

	local file_to_tar=$(basename "$1")
	local tar_file_name="${file_to_tar%%.*}.tar.gz"
	if [ "$#" -ge 2 ]; then
		tar_file_name="$2"
	fi

	if [ "$#" -eq 1 ]; then
		echo "taring into '$tar_file_name'"
	fi

	tar cf - "$1" -P | pv -s $(($(du -sk "$1" | awk '{print $1}') * 1024)) | pigz > "$tar_file_name"
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
