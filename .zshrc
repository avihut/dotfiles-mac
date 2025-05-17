# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
export LOCAL_BIN=/usr/local/bin
export HOME_BIN=$HOME/.local/bin
export PATH=$HOME_BIN:$LOCAL_BIN:$PATH

# node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Path to your oh-my-zsh installation.
export OMZ=$HOME/.oh-my-zsh

# source $HOME/lib/zsh-jj/zsh-jj.plugin.zsh
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
source /opt/homebrew/share/zsh-autopair/autopair.zsh
source /opt/homebrew/share/zsh-you-should-use/you-should-use.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export GPG_TTY=$(tty)

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
	jj
	colorize
	extract
	swiftpm
	direnv
)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

source $OMZ/oh-my-zsh.sh

# User configuration
export EDITOR='vim'

# Config settings
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

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

# Shell shortcuts
alias ls="eza --group-directories-first --icons"

# Dev flow shortcuts
alias p="pnpm"
alias pd="pnpm dev"
alias pt="pnpm test"
alias ptw="pnpm test:watch"
alias pu="pnpm up"
alias po="pnpm outdated"

bdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

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

# Function to create a git worktree one directory level up, create a new branch based on either
# the CURRENT branch or a specified base branch, push the new branch to origin, set upstream tracking,
# run 'direnv allow' (if direnv exists), and finally cd into the new worktree.
#
# !! Assumes you run this command from *within* an existing repository/worktree directory !!
#    The new worktree will be created alongside it (e.g., ../<new-branch-name>).
#
# Usage: gcbw <new-branch-name> [base-branch-name]
# (gcbw = Git New Worktree Branch)
#
# Arguments:
#    $1: new-branch-name    - The name for the new branch and the worktree directory. Required.
#    $2: base-branch-name   - The branch to base the new branch on. Optional.
#                             If omitted, defaults to the CURRENTLY CHECKED OUT branch.
#
# Example 1 (run from ~/projects/my-repo/main):
#    gcbw feature/new-login
#    -> Creates worktree at ~/projects/feature/new-login based on 'main', pushes & tracks, runs direnv, then cds into it.
#
# Example 2 (run from ~/projects/my-repo/main):
#    gcbw bugfix/hotfix-123 develop
#    -> Creates worktree at ~/projects/bugfix/hotfix-123 based on 'develop', pushes & tracks, runs direnv, then cds into it.
#
gcbw() {
  # Use local variables
  local new_branch_name=$1
  local base_branch # Will be set based on $2 or current branch

  # --- Configuration ---
  local remote_name="origin" # Remote for push/upstream
  # --- End Configuration ---

  # --- Determine Base Branch ---
  if [[ -n "$2" ]]; then
    # Use the explicitly provided base branch name
    base_branch="$2"
    echo "--> Using explicitly provided base branch: '$base_branch'"
  else
    # Base branch not specified, use the current branch
    echo "--> Base branch not specified, using current branch..."
    # Get the short symbolic name of the current HEAD (current branch)
    base_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    local exit_code=$?

    if [[ $exit_code -ne 0 ]] || [[ -z "$base_branch" ]]; then
      # Could fail if in detached HEAD state or other git issues
      echo "Error: Could not determine current branch (maybe detached HEAD?)." >&2
      echo "Please checkout a branch or specify the base branch explicitly:" >&2
      echo "Usage: gcbw <new-branch-name> [base-branch-name]" >&2
      return 1
    fi
    echo "--> Using current branch as base: '$base_branch'"
  fi
  # --- End Determine Base Branch ---

  # --- Define the worktree path ---
  local worktree_path="../${new_branch_name}"
  # --- End Path Definition ---

  # --- Input Validation ---
  if [[ -z "$new_branch_name" ]]; then
    echo "Error: New branch name is required." >&2
    echo "Usage: gcbw <new-branch-name> [base-branch-name (defaults to current branch)]" >&2
    echo "(Remember to run this from within your repository directory)" >&2
    return 1
  fi

  local original_dir=$(pwd)
  local real_worktree_path

  # --- Execution ---
  echo "Attempting to create Git worktree:"
  echo "  Path:         ${worktree_path} (relative to CWD: ${original_dir})"
  echo "  New Branch:   ${new_branch_name}"
  echo "  From Branch:  ${base_branch}" # Shows specified or current branch
  echo "---"

  # Step 1: Create the worktree and the local branch
  # Use base_branch variable here
  if git worktree add "$worktree_path" -b "$new_branch_name" "$base_branch"; then
    echo "---"
    # Get absolute path
    if command -v realpath &> /dev/null; then
      real_worktree_path=$(realpath -- "$worktree_path" 2>/dev/null || echo "$worktree_path")
    elif [[ "$worktree_path" = /* ]]; then
      real_worktree_path="$worktree_path"
    else
      real_worktree_path="$(\cd "$original_dir/.." && pwd)/${new_branch_name}"
    fi
    if [[ -z "$real_worktree_path" ]] || [[ ! -d "$real_worktree_path" ]]; then
       echo "Warning: Could not reliably determine absolute path for '${worktree_path}'. Using relative path." >&2
       real_worktree_path="$worktree_path"
    fi
    echo "Git worktree created successfully at '${real_worktree_path}'."

    # Step 2: Change directory into the new worktree
    echo "--> Changing directory to worktree: ${real_worktree_path}"
    if cd -- "$real_worktree_path"; then
        echo "--> Successfully changed directory to $(pwd)"

        # Step 3: Push, set upstream
        echo "--> Attempting: git push --set-upstream $remote_name \"$new_branch_name\""
        if git push --set-upstream "$remote_name" "$new_branch_name"; then
            echo "--> Push to '${remote_name}' and upstream tracking set successfully."

            # Step 4: Handle direnv (silently skip if not found)
            # Only proceed if direnv command exists
            if command -v direnv &> /dev/null; then
                echo "--> Running 'direnv allow'..."
                if [[ -f ".envrc" ]]; then
                    if direnv allow .; then
                        echo "--> 'direnv allow .' completed successfully."
                    else
                        # Still report failure if direnv exists but allow fails
                        echo "Warning: 'direnv allow .' failed. You may need to run it manually." >&2
                    fi
                else
                    echo "--> No .envrc file found in $(pwd). Skipping 'direnv allow'."
                fi
            # --- NO ELSE block here: Silently skip if direnv is not found ---
            fi
            echo "---"
            echo "Overall Success: Worktree created, branch pushed/tracked, direnv handled (if present), and CD'd into worktree."
            return 0 # Success

        else
            # Push failed
            local push_exit_code=$?
            echo "---"
            echo "Error: Failed to push branch '${new_branch_name}' to '${remote_name}' or set upstream (Exit code: ${push_exit_code})." >&2
            echo "Worktree was created at '$(pwd)', but push/tracking failed." >&2
            echo "You ARE currently in the new worktree directory: $(pwd)"
            echo "You may need to resolve the push issue manually." >&2
            return 1
        fi
    else
        # cd failed
        local cd_exit_code=$?
        echo "---"
        echo "Error: Failed to change directory to the new worktree path '${real_worktree_path}' (Exit code: ${cd_exit_code})." >&2
        echo "Worktree *may* have been created, but subsequent steps were skipped." >&2
        echo "You are still in the original directory: ${original_dir}"
        echo "Please check permissions and path." >&2
        cd -- "$original_dir" || echo "Warning: Could not return to original directory ${original_dir}" >&2
        return 1
    fi
  else
    # git worktree add failed
    local wt_exit_code=$?
    echo "---"
    echo "Error: Failed to create git worktree (Exit code: ${wt_exit_code})." >&2
    echo "Check path permissions, if base branch '$base_branch' exists locally and is valid," >&2
    echo "or if the target path '${worktree_path}' (relative to ${original_dir}) already exists." >&2
    return 1
  fi
}

# Function to create a git worktree and branch based on the REMOTE'S DEFAULT branch
# (e.g., main, master). It determines the default branch and then calls 'gcbw'.
#
# Usage: gcbdw <new-branch-name>
# (gcbdw = Git New Worktree Branch Default)
#
# Arguments:
#    $1: new-branch-name    - The name for the new branch and the worktree directory. Required.
#
# Example (assuming remote 'origin' default is 'main'):
#   gcbdw feature/cool-stuff
#   -> Determines default branch is 'main'
#   -> Effectively runs: gcbw feature/cool-stuff main
#
gcbdw() {
  # Use local variables
  local new_branch_name=$1
  local default_branch # To be detected
  local git_common_dir # Changed variable name for clarity
  local head_ref_file
  local head_ref_content

  # --- Configuration ---
  local remote_name="origin" # Remote to check for default branch
  # --- End Configuration ---

  # --- Input Validation ---
  if [[ -z "$new_branch_name" ]]; then
    echo "Error: New branch name is required." >&2
    echo "Usage: gcbdw <new-branch-name>" >&2
    return 1
  fi

  # --- Determine Default Branch (using file reading method) ---
  echo "--> Determining default branch for remote '$remote_name'..."

  # Use --git-common-dir to reliably find the shared .git directory path
  # This works correctly even when run from within a worktree.
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ -z "$git_common_dir" ]]; then
      # Check if maybe we are not in a git repo at all
      if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
         echo "Error: [gcbdw] Not inside a Git repository." >&2
         return 1
      fi
      # If we are in a repo, but --git-common-dir failed, something is odd
      echo "Error: [gcbdw] Could not determine Git common directory using 'git rev-parse --git-common-dir'." >&2
      echo "Your Git repository structure might be unusual. Please check your setup." >&2
      return 1
  fi

  # Construct the path to the file containing the default branch ref within the common dir
  head_ref_file="${git_common_dir}/refs/remotes/${remote_name}/HEAD"

  # Check if the reference file exists
  if [[ ! -f "$head_ref_file" ]]; then
      echo "Error: [gcbdw] Default branch reference file not found at '$head_ref_file'." >&2
      echo "Please ensure remote '$remote_name' exists and its HEAD is set correctly locally." >&2
      echo "(Have you fetched from the remote? Try: 'git remote set-head $remote_name --auto' and 'git fetch $remote_name')" >&2
      return 1
  fi

  # Read the content of the file (e.g., "ref: refs/remotes/origin/main")
  head_ref_content=$(<"$head_ref_file")

  # Check if the content starts with "ref: "
  if [[ "$head_ref_content" == ref:* ]]; then
      # Extract branch name using shell parameter expansion
      default_branch=${head_ref_content#ref: refs/remotes/$remote_name/}
      if [[ -z "$default_branch" ]] || [[ "$default_branch" == "$head_ref_content" ]]; then
           echo "Error: [gcbdw] Could not parse branch name from content of '$head_ref_file':" >&2
           echo "Content: '$head_ref_content'" >&2
           return 1
      fi
      echo "--> [gcbdw] Detected default origin branch: '$default_branch'"
  else
      # Content was not in the expected format
      echo "Error: [gcbdw] Unexpected content found in '$head_ref_file':" >&2
      echo "Content: '$head_ref_content'" >&2
      echo "Expected format: 'ref: refs/remotes/${remote_name}/<branch_name>'" >&2
      return 1
  fi
  # --- End Determine Default Branch ---

  # --- Call gcbw ---
  echo "--> [gcbdw] Calling gcbw '$new_branch_name' '$default_branch'..."
  # Execute gcbw with the new branch name and the detected default branch
  # Pass its exit code back up
  gcbw "$new_branch_name" "$default_branch"
  return $?
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

# Function to clone a Git repository into a specific directory structure:
# <repository_name>/<default_branch_name>
#
# It determines the repository name from the URL and queries the remote
# to find the default branch (e.g., main, master, develop) *before* cloning.
# After cloning, it runs 'direnv allow' in the new directory and cds into it.
#
# Usage: gclone <repository-url>
#
# Example:
#   gclone git@github.com:someuser/my-cool-project.git
#   -> Determines default branch (e.g., 'main')
#   -> Creates directory ./my-cool-project/main
#   -> Clones the repo into ./my-cool-project/main
#   -> Runs 'direnv allow .' in ./my-cool-project/main
#   -> Changes current directory to ./my-cool-project/main
#
gclone() {
  # --- Store Original Directory ---
  local original_dir=$(pwd)
  # --- End Store ---

  # --- Input ---
  local repo_url=$1
  # --- End Input ---

  # --- Tool Dependencies Check ---
  local missing_deps=0
  if ! command -v git &> /dev/null; then
    echo "Error: 'git' command not found. Please install Git." >&2
    missing_deps=1
  fi
  if ! command -v basename &> /dev/null; then
    echo "Error: 'basename' command not found. Cannot extract repository name." >&2
    missing_deps=1
  fi
   if ! command -v awk &> /dev/null; then
    echo "Error: 'awk' command not found. Cannot determine default branch." >&2
    missing_deps=1
  fi
  # We'll check for direnv later, only if needed
  if [[ "$missing_deps" -ne 0 ]]; then
    # Go back to original dir in case something went wrong before this point
    # (though unlikely with current structure)
    cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
    return 1 # Return error if dependencies are missing
  fi
  # --- End Tool Check ---


  # --- Input Validation ---
  if [[ -z "$repo_url" ]]; then
    echo "Error: Repository URL is required." >&2
    echo "Usage: gclone <repository-url>" >&2
    cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
    return 1
  fi
  # --- End Validation ---


  # --- Variable Declaration ---
  local repo_name
  local default_branch
  local parent_dir
  local clone_target_dir
  local head_ref_line
  # --- End Variable Declaration ---


  # --- Step 1: Extract Repository Name ---
  repo_name=$(basename "$repo_url" .git)
  repo_name=$(basename "$repo_name")

  if [[ -z "$repo_name" ]]; then
     echo "Error: Could not extract repository name from URL: '$repo_url'" >&2
     cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
     return 1
  fi
  echo "Repository name detected: '$repo_name'"
  # --- End Step 1 ---


  # --- Step 2: Determine Default Branch Remotely ---
  echo "Querying remote '$repo_url' for default branch..."
  head_ref_line=$(git ls-remote --symref "$repo_url" HEAD 2>/dev/null)

  if [[ -z "$head_ref_line" ]]; then
      echo "Error: Could not query remote HEAD ref for '$repo_url'." >&2
      echo "Please check the URL, network connectivity, and repository permissions." >&2
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1
  fi

  default_branch=$(echo "$head_ref_line" | awk '/^ref:/ {sub("refs/heads/", ""); print $2}')

  if [[ -z "$default_branch" ]]; then
      echo "Error: Could not parse default branch name from ls-remote output:" >&2
      echo "$head_ref_line" >&2
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1
  fi
  echo "Default branch detected: '$default_branch'"
  # --- End Step 2 ---


  # --- Step 3: Define and Create Directory Structure ---
  parent_dir="$repo_name"
  # Use relative path based on original directory for creation logic
  clone_target_dir="${original_dir}/${parent_dir}/${default_branch}"
  # Store relative path for user messages if realpath fails later
  local relative_clone_target_dir="${parent_dir}/${default_branch}"

  echo "Target clone directory: './${relative_clone_target_dir}'"

  # Check for potential conflicts before creating directories (using full path)
  if [[ -e "${original_dir}/${parent_dir}" && ! -d "${original_dir}/${parent_dir}" ]]; then
      echo "Error: A file (not a directory) already exists at '${original_dir}/${parent_dir}'." >&2
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1
  fi
   if [[ -e "$clone_target_dir" ]]; then
      echo "Error: Target path '$clone_target_dir' already exists." >&2
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1
  fi

  echo "Creating directory structure..."
  # Create using the full path for robustness if called from subdirs
  if ! mkdir -p "$clone_target_dir"; then
     echo "Error: Failed to create directory structure '$clone_target_dir'." >&2
     cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
     return 1
  fi
  echo "Directory structure created successfully."
  # --- End Step 3 ---


  # --- Step 4: Clone the Repository ---
  echo "Cloning '$repo_url' into '$clone_target_dir'..."
  # Clone using the full path
  if ! git clone "$repo_url" "$clone_target_dir"; then
      echo "Error: 'git clone' failed." >&2
      echo "Cleaning up created directories..." >&2
      # Clean up using full paths
      rmdir "$clone_target_dir" 2>/dev/null
      # Try removing parent only if it's likely the one we created
      # Check if parent dir relative to original_dir exists and is empty
      if [[ -d "${original_dir}/${parent_dir}" ]] && [[ -z "$(ls -A "${original_dir}/${parent_dir}")" ]]; then
           rmdir "${original_dir}/${parent_dir}" 2>/dev/null
      fi
      # Or more simply, remove the whole structure if clone fails:
      # rm -rf "${original_dir}/${parent_dir}"
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1
  fi
  # --- End Step 4 ---


  # --- Step 5: Post-Clone Actions (cd & direnv) ---
  echo "--> Changing directory to clone target: '$clone_target_dir'"
  # Use -- to handle potential paths starting with a hyphen
  if cd -- "$clone_target_dir"; then
      # Now we are inside the target directory
      local current_dir=$(pwd)
      echo "--> Successfully changed directory to $current_dir"

      # Step 5a: Run direnv allow if available
      echo "--> Running 'direnv allow' in $current_dir..."
      if command -v direnv &> /dev/null; then
          # Check if .envrc exists before running allow
          if [[ -f ".envrc" ]]; then
              if direnv allow .; then
                  echo "--> 'direnv allow .' completed successfully."
              else
                  echo "Warning: 'direnv allow .' failed in $current_dir. You may need to run it manually." >&2
                  # Continue even if direnv fails, as clone and cd succeeded
              fi
          else
              echo "--> No .envrc file found in $current_dir. Skipping 'direnv allow'."
          fi
      else
          echo "--> 'direnv' command not found. Skipping 'direnv allow'."
      fi

      # Step 5b: Final Success Message (already in the correct directory)
      echo "---"
      echo "Success!"
      # Use pwd for the most accurate current directory path
      local abs_clone_dir="$current_dir"
      # Try to get absolute path for parent for clarity
      local abs_parent_dir
      abs_parent_dir=$(realpath -- "$current_dir/.." 2>/dev/null || echo "${original_dir}/${parent_dir}") # Fallback

      echo "Repository '$repo_name' cloned into '$abs_clone_dir'"
      echo "Parent directory structure created at '$abs_parent_dir'"
      echo "You are now inside the cloned repository directory."

      # Since we successfully cd'd, we just return 0 and the shell stays here.
      return 0 # Indicate success

  else
      # cd failed!
      local cd_exit_code=$?
      echo "---"
      echo "Error: Clone succeeded, but failed to change directory to '$clone_target_dir' (Exit code: ${cd_exit_code})." >&2
      echo "You are still in the original directory: ${original_dir}" >&2
      echo "Please check permissions for the target directory." >&2
      # No direnv attempted because cd failed
      # Attempt to cd back just in case something intermediate happened, though unlikely
      cd -- "$original_dir" || echo "Warning: could not cd back to $original_dir" >&2
      return 1 # Indicate failure
  fi
  # --- End Step 5 ---
}

# Function to create a git worktree one directory level up, checking out an EXISTING branch,
# set upstream tracking to the corresponding remote branch (if it exists),
# run 'direnv allow' (if direnv exists), and finally cd into the new worktree.
#
# !! Assumes you run this command from *within* an existing repository/worktree directory !!
#    The new worktree will be created alongside it (e.g., ../<existing-branch-name>).
#
# Usage: gcw <existing-branch-name>
# (gcw = Git Checkout Worktree)
#
# Arguments:
#    $1: existing-branch-name - The name of the EXISTING local or remote branch to check out
#                               and the name for the new worktree directory. Required.
#                               If only a remote branch exists (e.g., origin/feature/abc),
#                               Git usually creates the local branch automatically.
#
# Example (run from ~/projects/my-repo/main):
#    gcw feature/existing-feature
#    -> Creates worktree at ~/projects/feature/existing-feature checking out 'feature/existing-feature',
#       sets upstream to 'origin/feature/existing-feature', runs direnv, then cds into it.
#
gcw() {
  # Use local variables
  local branch_name=$1 # Renamed for clarity

  # --- Configuration ---
  local remote_name="origin" # Remote for upstream tracking
  # --- End Configuration ---

  # --- Define the worktree path ---
  # Use the provided branch name for the directory name
  local worktree_path="../${branch_name}"
  # --- End Path Definition ---

  # --- Input Validation ---
  if [[ -z "$branch_name" ]]; then
    echo "Error: Existing branch name is required." >&2
    echo "Usage: gcw <existing-branch-name>" >&2
    echo "(Remember to run this from within your repository directory)" >&2
    return 1
  fi

  # --- Preliminary Checks ---
  # Optional: Check if the branch exists locally or remotely beforehand?
  # `git show-ref --verify --quiet refs/heads/"$branch_name"` checks local
  # `git show-ref --verify --quiet refs/remotes/"$remote_name"/"$branch_name"` checks remote
  # `git worktree add` will fail anyway if it doesn't exist in some form, so maybe skip explicit check.

  local original_dir=$(pwd)
  local real_worktree_path

  # --- Execution ---
  echo "Attempting to create Git worktree and checkout branch:"
  echo "  Path:         ${worktree_path} (relative to CWD: ${original_dir})"
  echo "  Branch:       ${branch_name}"
  echo "---"

  # Step 1: Create the worktree and checkout the existing branch
  # Note: No '-b'. We provide the branch name directly.
  # If 'branch_name' exists locally, it checks it out.
  # If it only exists on 'remote_name', Git typically creates a local tracking branch.
  if git worktree add "$worktree_path" "$branch_name"; then
    echo "---"
    # Get absolute path
    if command -v realpath &> /dev/null; then
      real_worktree_path=$(realpath -- "$worktree_path" 2>/dev/null || echo "$worktree_path")
    elif [[ "$worktree_path" = /* ]]; then
      real_worktree_path="$worktree_path"
    else
      # Attempt to construct absolute path robustly
      # Handle potential '..' in branch_name (though unlikely/bad practice)
      local target_dir_name=$(basename -- "$worktree_path")
      real_worktree_path="$(\cd "$original_dir/.." && pwd)/${target_dir_name}"
    fi
     if [[ -z "$real_worktree_path" ]] || [[ ! -d "$real_worktree_path" ]]; then
       echo "Warning: Could not reliably determine absolute path for '${worktree_path}'. Using relative path." >&2
       real_worktree_path="$worktree_path"
     fi
    echo "Git worktree created successfully at '${real_worktree_path}' checking out branch '${branch_name}'."

    # Step 2: Change directory into the new worktree
    echo "--> Changing directory to worktree: ${real_worktree_path}"
    if cd -- "$real_worktree_path"; then
        echo "--> Successfully changed directory to $(pwd)"

        # Step 3: Set upstream tracking (if corresponding remote branch exists)
        local remote_branch_ref="refs/remotes/${remote_name}/${branch_name}"
        echo "--> Checking for remote branch '${remote_name}/${branch_name}'..."
        if git show-ref --verify --quiet "$remote_branch_ref"; then
            echo "--> Remote branch found. Attempting: git branch --set-upstream-to=${remote_name}/${branch_name}"
            # We are now IN the worktree, on the branch 'branch_name', so we can set upstream directly
            if git branch --set-upstream-to="${remote_name}/${branch_name}"; then
                echo "--> Upstream tracking set successfully to '${remote_name}/${branch_name}'."
            else
                local upstream_exit_code=$?
                echo "---"
                echo "Warning: Failed to set upstream tracking for branch '${branch_name}' to '${remote_name}/${branch_name}' (Exit code: ${upstream_exit_code})." >&2
                echo "         Worktree created and CD'd into, but upstream may need manual configuration." >&2
                # Decide whether this is a fatal error or just a warning. Let's treat as warning.
            fi
        else
            echo "--> Remote branch '${remote_name}/${branch_name}' not found. Skipping upstream setup."
            echo "    You might need to push the branch or check the remote name/branch name."
        fi

        # Step 4: Handle direnv (silently skip if not found)
        # Only proceed if direnv command exists
        if command -v direnv &> /dev/null; then
            echo "--> Running 'direnv allow'..."
            if [[ -f ".envrc" ]]; then
                if direnv allow .; then
                    echo "--> 'direnv allow .' completed successfully."
                else
                    # Still report failure if direnv exists but allow fails
                    echo "Warning: 'direnv allow .' failed. You may need to run it manually." >&2
                fi
            else
                echo "--> No .envrc file found in $(pwd). Skipping 'direnv allow'."
            fi
        # --- NO ELSE block here: Silently skip if direnv is not found ---
        fi
        echo "---"
        echo "Overall Success: Worktree created, branch checked out, upstream handled, direnv handled (if present), and CD'd into worktree."
        return 0 # Success

    else
      # cd failed
      local cd_exit_code=$?
      echo "---"
      echo "Error: Failed to change directory to the new worktree path '${real_worktree_path}' (Exit code: ${cd_exit_code})." >&2
      echo "Worktree *may* have been created, but subsequent steps were skipped." >&2
      echo "You are still in the original directory: ${original_dir}"
      echo "Please check permissions and path." >&2
      # Attempt to clean up the potentially created but unusable worktree? Optional, maybe too destructive.
      # git worktree remove --force "$worktree_path" # Be careful with this
      cd -- "$original_dir" || echo "Warning: Could not return to original directory ${original_dir}" >&2
      return 1
    fi
  else
    # git worktree add failed
    local wt_exit_code=$?
    echo "---"
    echo "Error: Failed to create git worktree (Exit code: ${wt_exit_code})." >&2
    echo "Check if branch '$branch_name' exists locally or remotely ('$remote_name/$branch_name')," >&2
    echo "check path permissions, or if the target path '${worktree_path}' (relative to ${original_dir}) already exists." >&2
    return 1
  fi
}


# pnpm
export PNPM_HOME="/Users/avihu/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export GPG_TTY=$(tty)

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/avihu/.cache/lm-studio/bin"
# End of LM Studio CLI section
