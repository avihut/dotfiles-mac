export HOME_BIN=$HOME/bin
export LOCAL_BIN=/usr/local/bin
export BOOST_ROOT=/usr/local/lib/boost/boost_1_64_0
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_TOOLS=$ANDROID_HOME/tools
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools
export HOME_LIB="$HOME/lib"
export FLUTTER_LIB="$HOME_BIN/flutter"
export FLUTTER_BIN="$FLUTTER_LIB/bin"
export POSTGRESSQL="/Library/PostgreSQL/13/bin/"
export LIBEXEC=/usr/libexec
export PROJECT_HOME=$HOME/Projects
export HYDRA_HOME=$PROJECT_HOME/Hydra/bin
export BREEZE_HOME=$HOME/Breeze/Projects/main
export PUB_CACHE_HOME=$HOME/.pub-cache/bin
export BUN_BIN=$HOME/.bun/bin
export PATH=$BUN_BIN:$PUB_CACHE_HOME:$BREEZE_HOME:$POSTGRESSQL:$LIBEXEC:$FLUTTER_BIN:$BOOST_ROOT:$HOME_BIN:$LOCAL_BIN:$ANDROID_TOOLS:$ANDROID_PLATFORM_TOOLS:$HYDRA_HOME:$PATH

# node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

eval "$(rbenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
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
	swiftpm
	direnv
)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias g='googler -n 7 -l en'

alias cdflutter='cd $FLUTTER_LIB'

alias venv='python -m venv'

alias n='nocorrect'

alias hydrate='n workon hydra'

# git shortcuts
alias gdst='gd --staged'
alias gcvm='git commit -v -m'
alias gcvsm='git commit -v -S -m'
alias gadc='git add -u'
alias gadu='git add $(git ls-files -o --exclude-standard)'
alias glop='git log --oneline --patch'
alias gc-b='git checkout -b'
alias pipup="python3 -m pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 python3 -m pip install -U"
alias brewup='brew upgrade && brew cleanup && brew cleanup --prune-prefix'
alias ggroom='git remote prune origin && git gc --prune=now'
alias gbranches='nocorrect git branch -r | grep -v HEAD | while read b; do git log --color --format="%ci _%C(magenta)%>(15)%cr %C(bold blue)%<(16)%an%Creset %C(bold cyan)$b%Creset %s" $b | head -n 1; done | sort -r | cut -d_ -f2- | sed "s;origin/;;g"'

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# The next line updates PATH for the Google Cloud SDK.
# if [ -f "${HOME_BIN}/google-cloud-sdk/path.zsh.inc" ]; then . "${HOME_BIN}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
# if [ -f "${HOME_BIN}/google-cloud-sdk/completion.zsh.inc" ]; then . "${HOME_BIN}/google-cloud-sdk/completion.zsh.inc"; fi

# Added by Windsurf
export PATH="/Users/avihu/.codeium/windsurf/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/avihu/.cache/lm-studio/bin"

# Function to create a git worktree one directory level up, create a new branch based on an origin branch (defaulting to master),
# push the new branch to origin, set upstream tracking, run 'direnv allow', and finally cd into the new worktree.
#
# !! Assumes you run this command from *within* your main repository directory !!
#    The new worktree will be created alongside it (e.g., ../<new-branch-name>).
#
# Usage: gnwb <new-branch-name> [origin-branch-name]
# (gnwb = Git New Worktree Branch)
#
# Arguments:
#   $1: new-branch-name   - The name for the new branch and the worktree directory. Required.
#   $2: origin-branch-name - The branch to base the new branch on. Optional, defaults to 'master'.
#                           (Consider changing 'master' to 'main' if that's your default branch name).
#
# Example 1 (run from ~/projects/my-repo):
#   gnwb feature/new-login
#   -> Creates worktree at ~/projects/feature/new-login based on 'master', pushes & tracks, runs direnv, then cds into it.
#
# Example 2 (run from ~/projects/my-repo):
#   gnwb bugfix/hotfix-123 develop
#   -> Creates worktree at ~/projects/bugfix/hotfix-123 based on 'develop', pushes & tracks, runs direnv, then cds into it.
#
gnwb() {
  # Use local variables to avoid polluting the global namespace
  local new_branch_name=$1
  # --- Configuration ---
  # Set the default origin branch name here. Change 'master' to 'main' if needed.
  local default_origin_branch="master"
  # Set the remote name to push to.
  local remote_name="origin"
  # --- End Configuration ---

  # Use the provided origin branch ($2) if it exists, otherwise use the default.
  local origin_branch=${2:-$default_origin_branch}

  # --- Define the worktree path ---
  # Create the worktree directory one level up relative to the current directory.
  local worktree_path="../${new_branch_name}"
  # --- End Path Definition ---

  # --- Input Validation ---
  if [[ -z "$new_branch_name" ]]; then
    echo "Error: New branch name is required." >&2
    echo "Usage: gnwb <new-branch-name> [origin-branch-name (defaults to ${default_origin_branch})]" >&2
    echo "(Remember to run this from within your main repository directory)" >&2
    return 1 # Return non-zero status to indicate failure
  fi

  # Store the original directory in case we need to report errors accurately
  local original_dir=$(pwd)
  local real_worktree_path # Variable to store the calculated absolute path

  # --- Execution ---
  echo "Attempting to create Git worktree:"
  echo "  Path:          ${worktree_path} (relative to CWD: ${original_dir})"
  echo "  New Branch:    ${new_branch_name}"
  echo "  From Branch:   ${origin_branch}"
  echo "---"

  # Step 1: Create the worktree and the local branch
  if git worktree add "$worktree_path" -b "$new_branch_name" "$origin_branch"; then
    echo "---"
    # Attempt to get the absolute path for clarity and for the final cd
    if command -v realpath &> /dev/null; then
      real_worktree_path=$(realpath -- "$worktree_path") # Use -- to handle paths starting with -
    elif [[ "$worktree_path" = /* ]]; then
      real_worktree_path="$worktree_path"
    else
      # Basic attempt for relative paths like ../ - calculate from original_dir
      real_worktree_path="$(cd "$original_dir/.." && pwd)/${new_branch_name}"
    fi
    # Verify the path calculation worked reasonably
    if [[ -z "$real_worktree_path" ]] || [[ ! -d "$real_worktree_path" ]]; then
        echo "Warning: Could not reliably determine absolute path for '${worktree_path}'. Using relative path." >&2
        real_worktree_path="$worktree_path" # Fallback to relative
    fi
    echo "Git worktree created successfully at '${real_worktree_path}'."


    # Step 2: Change directory into the new worktree. This cd affects the calling shell.
    echo "--> Changing directory to worktree: ${real_worktree_path}"
    if cd -- "$real_worktree_path"; then # Use -- to handle paths starting with -
         echo "--> Successfully changed directory to $(pwd)"

         # Step 3: Push, set upstream (already in the correct directory)
         echo "--> Attempting: git push --set-upstream $remote_name \"$new_branch_name\""
         if git push --set-upstream "$remote_name" "$new_branch_name"; then
             echo "--> Push to '${remote_name}' and upstream tracking set successfully."

             # Step 4: Handle direnv (already in the correct directory)
             echo "--> Running 'direnv allow'..."
             if command -v direnv &> /dev/null; then
                 if direnv allow .; then
                     echo "--> 'direnv allow' completed successfully."
                 else
                     echo "Warning: 'direnv allow' failed. You may need to run it manually." >&2
                 fi
             else
                 echo "--> 'direnv' command not found. Skipping 'direnv allow'."
             fi
             echo "---"
             echo "Overall Success: Worktree created, branch pushed/tracked, direnv handled, and CD'd into worktree."
             # We are already in the new directory, so just return success.
             return 0 # Success

         else
             # Push failed (but cd succeeded)
             local push_exit_code=$?
             echo "---"
             echo "Error: Failed to push branch '${new_branch_name}' to '${remote_name}' or set upstream (Exit code: ${push_exit_code})." >&2
             echo "Worktree was created at '${real_worktree_path}', but push/tracking failed." >&2
             echo "You ARE currently in the new worktree directory: $(pwd)" # Clarify location
             echo "You may need to resolve the push issue manually." >&2
             return 1 # Indicate failure (but note that cd was successful)
         fi
    else
         # cd failed!
         local cd_exit_code=$?
         echo "---"
         echo "Error: Failed to change directory to the new worktree path '${real_worktree_path}' (Exit code: ${cd_exit_code})." >&2
         echo "Worktree *may* have been created, but subsequent steps (push, direnv) were skipped." >&2
         echo "You are still in the original directory: ${original_dir}"
         echo "Please check permissions and path." >&2
         return 1 # Indicate failure
    fi

  else
    # git worktree add failed
    local wt_exit_code=$?
    echo "---"
    echo "Error: Failed to create git worktree (Exit code: ${wt_exit_code}). Check path permissions and if '${worktree_path}' (relative to ${original_dir}) already exists." >&2
    # cd command was not attempted, user is still in original directory.
    return 1 # Indicate failure
  fi
}

# Function to prune local Git branches whose remote counterparts have been deleted,
# ensuring any associated worktrees are removed first.
gprune() {
  # --- Configuration ---
  local REMOTE_NAME="origin"
  local branch_name # Declare loop variables as local
  local worktree_path
  local branches_deleted=0
  local worktrees_removed=0
  local gone_branches=() # Array to hold branches to prune
  local line branch_ref tracking_status # Variables for reading loop
  local target_branch_ref current_path # Variables for porcelain parsing

  # Ensure we are in a git repository
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a Git repository." >&2
    return 1 # Use return instead of exit in functions
  fi

  echo "Fetching from remote '$REMOTE_NAME' and pruning stale remote-tracking branches..."
  if ! git fetch "$REMOTE_NAME" --prune; then
    echo "Error: 'git fetch $REMOTE_NAME --prune' failed. Aborting." >&2
    return 1
  fi

  echo "Identifying local branches whose upstream branch is gone..."
  # Only process local head refs that are tracking a remote branch which is now gone
  while IFS= read -r line; do
      branch_ref=$(echo "$line" | awk '{print $1}')
      tracking_status=$(echo "$line" | awk '{print $2}') # Assumes simple format

      if [[ "$tracking_status" == "[gone]" ]]; then
          branch_name=${branch_ref#refs/heads/}
          gone_branches+=("$branch_name")
      fi
  done < <(git for-each-ref --format='%(refname) %(upstream:track)' refs/heads | grep '\[gone\]')


  if [[ ${#gone_branches[@]} -eq 0 ]]; then
    echo "No local branches found tracking deleted remote branches. Nothing to do."
    return 0
  fi

  echo "Found ${#gone_branches[@]} branches to potentially prune:"
  printf -- " - %s\n" "${gone_branches[@]}"
  echo ""

  # Iterate over the branches identified as 'gone'
  for branch_name in "${gone_branches[@]}"; do
    echo "--- Processing branch: '$branch_name' ---"

    # --- Check for Worktree using --porcelain (More Robust) ---
    # echo "Checking for associated worktree using porcelain format..." # Optional debug msg
    target_branch_ref="refs/heads/$branch_name"
    worktree_path="" # Reset for each branch
    current_path=""  # Track path for the current block

    # Use process substitution to feed porcelain output to the loop
    # Process last line even if no newline using || [[ -n "$line" ]]
    while IFS= read -r line || [[ -n "$line" ]]; do
      # Check if line starts with "worktree "
      if [[ "$line" == worktree* ]]; then
        # Extract path after "worktree "
        current_path="${line#worktree }"
        # Reset found path for the *next* block unless branch matches this block
        worktree_path=""
      # Check if line starts with "branch " and matches the target ref for the *current* block
      elif [[ -n "$current_path" && "$line" == "branch $target_branch_ref" ]]; then
        # Found the matching branch line for the worktree block defined by current_path
        worktree_path="$current_path"
        # Found the worktree for this branch, exit the sub-shell reading porcelain output
        break
      # Reset current_path at the end of a block (empty line) - Helps if break isn't used/fails
      elif [[ -z "$line" ]]; then
         current_path=""
      fi
    done < <(git worktree list --porcelain)
    # --- End Worktree Check ---


    if [[ -n "$worktree_path" ]]; then
      echo "Found associated worktree for '$branch_name' at: '$worktree_path'"

      # Check if the path *directory* exists (more reliable than -e for worktree path)
      # Quoting is crucial here for paths with spaces
      if [[ -d "$worktree_path" ]]; then
        echo "Attempting to remove worktree..."
        # Use --force because the associated branch is about to be deleted anyway
        # Quote the path variable to handle spaces
        if git worktree remove --force "$worktree_path"; then
          echo "Worktree at '$worktree_path' removed successfully."
          ((worktrees_removed++))
        else
          echo "Error: Failed to remove worktree '$worktree_path'. Skipping deletion of branch '$branch_name'." >&2
          continue # Skip to next branch
        fi
      else
        # Path doesn't exist, maybe manually deleted? Git command might still be needed.
        echo "Warning: Worktree directory '$worktree_path' not found. Attempting 'git worktree prune' might be needed separately." >&2
        echo "Attempting to force remove the worktree record anyway..."
        # Try removing the possibly orphaned record, still skip branch deletion on failure
        if git worktree remove --force "$worktree_path"; then
           echo "Worktree record for '$worktree_path' removed successfully."
           ((worktrees_removed++))
        else
           echo "Error: Failed to remove potentially orphaned worktree record '$worktree_path'. Skipping deletion of branch '$branch_name'." >&2
           continue # Skip to next branch
        fi
      fi
    else
      echo "No associated worktree found for '$branch_name'."
    fi

    # Now, attempt to delete the local branch
    echo "Attempting to delete local branch '$branch_name'..."
    # Quote the branch name variable to handle spaces/special chars
    if git branch -D "$branch_name"; then
      echo "Local branch '$branch_name' deleted successfully."
      ((branches_deleted++))
    else
      echo "Error: Failed to delete branch '$branch_name'." >&2
    fi
    echo "----------------------------------------" # Separator
  done

  echo ""
  echo "--- Summary ---"
  echo "Branches deleted: $branches_deleted"
  echo "Worktrees removed: $worktrees_removed"
  echo "Pruning process complete."

  # Check if any worktrees might need manual pruning
  if git worktree list | grep -q 'prunable'; then
     echo ""
     echo "Note: Some prunable worktree data may exist. Run 'git worktree prune' to clean up."
  fi

  return 0 # Indicate success
}


# pnpm
export PNPM_HOME="/Users/avihu/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
