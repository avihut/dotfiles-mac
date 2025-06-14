# Mac Dev Machine Configuration
## Setup
This explainer guide you through setting up a standard Mac Dev machine with zsh, iTerm2 terminal, powerlevel10k terminal theme, and basic pacakges you'll need for most workflows. By the end of it you'll have VS Code with a basic set of extensions installed through brew. Follow these installation instructions to have the set of recommended configurations.

1. Set your login shell to `zsh`.
2. Install [iTerm2](https://iterm2.com/downloads.html).
3. Install Homebrew (`brew`)

    ```shell
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

4. Install [oh my zsh](https://ohmyz.sh/)
5. Set up your Github SSH connection by [generating a local SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent), and then [adding the generated public key to your Github account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).
6. Checkout the configurations from this repository by following the Configuration Tracking instructions or just downloading files directly from this repository. The important files are `.zshrc`, `Brewfile`, and the `.vim` folder. Place them in your home folder (`~` / `$HOME`). You may encounter errors when opening a new terminal at this point. Ignore them. They will disappear after finishing the configuration.
7. Install all recommended brew packages by running

    ```shell
    brew bundle install
    ```

    _This may take several minutes. Go socialize. Make new friends. They will admire you after you finish this set up and flaunt your top-tier shell._

8. Open a new terminal to start setting up your `powerlevel10k` zsh theme. It may require you to quit and reopen your Terminal. Follow its instructions to completion.

Your terminal should be all set up and ready for work with a pimped up hacker shell.

### Configuration Tracking

It's recommended you first fork this repository to your own account to make sure that when you update it, you update it for yourself and not for everyone.

1. Clone the repository to a configuration directory called `.cfg` under youe home directory
    ```shell
    git clone --bare git@github.com:avihut/dotfiles-mac.git ~/.cfg
    ```

2. Checkut the configuration
    ```shell
    git --git-dir="$HOME/.cfg" --work-tree="$HOME" checkout -f --
    ```

3. Apply configuration changes
    ```shell
    exec zsh
    ```

4. `alias` the configuration command (done automatically in [`.zshrc`](.zshrc#L89))
    ```
    alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
    ```

## Shortcuts
- `gcvm`: `git commit -v -m <message>`
- `gadc`: `git add` tracked files.
- `gadu`: `git add` untracked files.
- `ggpush`: `git push origin <current branch>`. Though when upstream is propetly set up `git push` is enough.
- `glog`: `git log --oneline --decorate --graph`. A textual tree representation of the git history from current head.
- `gst`: `git status`
- `gd`: `git diff`
- `gdst`: `gd --staged`. Show changes in already staged files.

## Workflows
Recommendations and guides on different dev workflows.

### `.env` based configurations
This workflow helps isolate configurations to your project folders instead of having them in your rc files (`.bashrc` / `.zshrc`) and pollute all of your terminal.

The workflow pivots around the commonly used `.env` file, which is a file that sets environment variables for the directory it's in and all subdirectories below it. The workflow also relies on `direnv` which manages loading and unloading `.env` variables in your shell. Commonly used applications and platforms like React, Next, and pipenv load .env configurations on their own if they detect the file. The fully extended workflow also uses `.env.example` to define a template for `.env` in your project; `.envrc` for configuring your project directory; and `.env.base` if using the git worktree workflow.

#### `.env` file
A file that contains all the environment variables for your project in simple shell format, e.g.

```shell
NODE_ENV="development"
```

This file will be loaded automatically by most common platforms and applications like React, Next, and pipenv, and can also be easily used in some consoles for quickly uploading project configurations to deployment environments.

#### `direnv`
A command line utility for loading and unloading `.env` files to your terminal shell. For safety you must run `direnv allow` on directories that have new or changed `.env` configurations. Your terminal will let you know if you need to run it. direnv will also always print to the shell when it ran and when it loaded and unloaded `.env` configurations.

While your platform (React / Next) will load your `.env` configuration automatically, it's important to note that it will do so only for its run instance. The reason you want the direnv utility is if you have shell configurations you'd have stored in your `.bashrc` file, like `PYTHONPATH` or `PIPENV_VENV_IN_PROJECT`. These configurations need to be loaded into your shell, and better kept apart between projects.

direnv also runs `.envrc` files if present. These files can be used to run configuration scripts of your project folder.

#### `.envrc` file
This is a script file that is best used for project specific scripts and configuration you need to be applied whenever you enter your project folder. **Since this file will run every time you enter the folder, make sure to put here scripts that run very quick and you really must have.**

This is a good place for having scripts for installing packages and basic project setup that you usually run post-clone. For instance you may want to have a script for running `npm install` if it detects the `node_modules` folder is missing. Or create `.env` file from `.env.example` or `.env.base`.

#### `.env.example`
A good practice for projects that rely on a `.env` configuration is that they have a `.env.example` file which is a blank template denoting all of the configurations that need to be set up for this project.

#### `.env.base`
Only relevant if using the git worktree workflow. It's a filled up `.env` file with actual values that should reside in your project root directory next to your branch folders, and new branches will create their `.env` file from it.

### git worktree
The git worktree flow is a flow in which you checkout each branch to its own directory. It relies heavily on the `.env` workflow. I believe this workflow offers two very tangible benefits:
1. **Easy switching branch switching**. Many times people don't want to switch branches because they have dirty workfolders with uncommitted changes they still want to work on or unpushed changes. This results in either differing branch switching or usage of hard to track mechanisms like `git stash`. When you have your branches in different folders, you just move to a different folder.
2. **Cleaner project over time**. When doing all of your work over time you may incur untracked changes in `.env` or other such files in your folder that make it work the way you like it. This divergence is by nature hard to track and replicate. By forcing yourself to replicate it all of the time, you're forced to make sure it works and is easily recreatable.

This workflow utilizies the worktree feature of git which is the directory in which git checks out the files from the repository. Git has two main things it manages. The `.git` folder into which it clones the objects it manages for tracking project changes, and the worktree which is the directory into which it "unfolds" the repository files for a given commit. In regular git usage you have a single project folder you cloned from the Github repository which has the `.git` folder and the project files in it. This is a single worktree workflow and is the default usage of git out of the box.

In git worktree you have a root dir for your project, and inside it a a folder for each branch. But you will not clone the project into each dir seperately. You'll have a single `.git` folder that will manage your worktrees and branches.

```
project
├── master
├── feature-branch
└── hotfix
```

The workflow uses this set of commands already defined in this repository's `.zshrc` file:
- `gclone`: Clone a repository in worktree mode.
- `gcw`: Checkout an existing branch to a new worktree.
- `gcbw`: Create a new branch into a new worktree.
- `gprune`: Remove local branches and worktrees that were removed on remote.

#### Workflow
1. Go to your projects folder wherein you'd want to clone your Github project.
2. Run the command `gclone <repository URL>`. This will clone the repository in worktree mode creating a root folder with the repository name (like `git clone` does), and under it it will place a the a folder with the default branch (`master` / `main`) into which it will clone the project.
3. Create a new branch using `gcbw`. This will create a new branch, create a worktree for it, and move you to that worktree.
4. Once you finished your work on the branch, and it has merged to master, `cd` back to your `master` folder, and run `git pull` to bring the merged changes to master, followed by `gprune`. This will clean local branches and worktrees that have already been removed from the origin.

To have a `.env` template that will be shared between your branch folders, configure your project's `.envrc` to create a `.env` from an `.env.base` from one folder up, and create fully configured `.env.base` in your project root folder.

#### `gclone`
_`git clone`_

Takes a repository URL, and clones it in worktree mode. It will create a directory with the name of the repository like `git clone` does, and under it create a folder with the name of the default branch (`master` / `main` / etc. It auto-detects that branch). This command as easy entry point to the git worktree workflow.

```
gclone git@github.com:<user>/<repo>.git
```

#### `gcbw`
_`git checkout branch worktree`_

Use this to create new branches from your current branch. This is a logical extension of `git checkout -b` in the worktree workflow.

```
gcbw feature-branch
```

This command does a lot
- Creates a new branch with the provided name.
- Creates a the branch in origin.
- Sets up the local branch to have the remote branch in origin as its upstream.
- Checks out the new branch into a new worktree with the name of the branch as the folder under your project's root.
- Runs `direnv allow` on the new folder to be able to use its `.env` and `.envrc` configurations.
- Changes directory to the newly created directory.

The command can also accept a second argument of a branch from which to diverge from. By default it branches out from the current branch.

```
gcbw hotfix-branch release-branch
```

#### `gcw`
_`git checkout worktree`_

Checkout an existing branch to a new local worktree. This command is a logical extension of `git checkout` in the worktree workflow. It does everything the `gcbw` command does except creating the branch. It will create a worktree for it, run `direnv allow`, and change directory to it.

```
gcw existing-branch-name
```

#### `gcbdw`
_`git checkout default branch worktree`_

A variant of `gcbw` that takes one argument of a branch name and creates from the default branch of the repository. It autodetects the default branch.

For a project with `master` as the default branch running:

```
gcbdw branch-name
```

Is equivalent to running

```
gcbw branch-name master
```

#### `gprune`
_`git prune`_

A command for cleaning local branches and worktrees that have already been removed from origin. It takes no arguments.

Let's say you finished working on your feature branch. You closed your IDE. You go to your `master` directory and you run `git pull` to fetch the changes into from remote. The remote branch has already been removed. Removing the local branch and worktree is a bit cumbersome, but `gprune` takes care of it for you. In your `master` folder just run

```
gprune
```

And it will detect the removed remote branches, delete their local equivalents from git and remove their worktree folders.

This command is destructive. If you have any untracked changes or untracked files in neglected folders, they will be removed without asking.

#### Caveats
When using in the worktree workflow one must be aware of limitations of worktrees. There aren't many, but they can be annoying when encountered.

- You can't checkout a branch in one worktree folder if it's already checked out in a different worktree folder.
- You can't delete a branch without deleting its worktree.
- You can't update a branch that is checked out in a different worktree. Let's say you're on your feature branch, and want to update your `master` branch. You have to `cd` to the `master` worktree folder, run `git pull` from there, and then rebase your feature branch from its worktree folder. Not a biggy, but something to bare in mind.

### git squash Before Rebase
First of all the suggestion is that when you have a feature branch to rebase from master as often as possible. The bigger the divergence the more work it will be to fix potential conflicts, and worse the update code pertaining to your work that was added between your branching out and merging back to master.

In times where you have a long history on your feature branch that has a lot of conflicts with master you may want to squash your branch history before rebasing to minimize conflict resolution along your history so that you'll resolve it only once for your branch.

Bare in mind that rebasing rewrites git history. So it's recommended that you first push your branch to origin to have it backed up in case something goes wrong locally. After rebasing you'll need to force push to your branch.

1. Start a rebase from the divergence point from your default branch (change `master` to `main` if necessary)
    ```shell
    git rebase -i $(git merge-base master HEAD)
    ```

2. Mark the commits you want to squash

    vim will open with the list of commits to rebase
    ```
    pick b2bba48 Created an important-files mdc guide for Cursor
    pick 99988bb Layout and copy updates
    pick 69b5e77 Removed hover chevron on Job Card
    ```

    Each line is a commit made to your branch after divergence from master, and `git-rebase` is asking you what do with them. You want to squash all of your commits into your most recent commit.

   Leave the top-most commit with `pick`. Change `pick` to `s` (squash) for all commits below it (to edit in vim enter Insert mode by clicking `i`)
    ```
    pick b2bba48 Created an important-files mdc guide for Cursor
    s 99988bb Layout and copy updates
    s 69b5e77 Removed hover chevron on Job Card
    ```

3. Save and exit vim. Go back to Command mode by clicking the `esc` key. And either type `ZZ` (shift + zz) or `:wq`. Git will now squash your commits.

4. Another vim will open prompting you for the commit message of the new squashed commit. You can leave it as is. Sve and exit.

5. Rebase your branch on `master`
    ```shell
    git rebase master
    ```

6. Resolve conflicts if necessary.

7. Force push to origin
    Following the squash and the rebase your history has been rewritten by rebase, and is out of sync from your corresponding remote branch on origin. To push your changes to it you'll need to ovewrite it by force pushing
   ```shell
   git push --force-with-lease
   ```

   The `--force-with-lease` argument differs from `--force` in subtle but significant way - it allows you to force push to the remote branch **only if you were the last person to push to it**. Meaning that if someone pushed to that branch before you, **your force push will fail**, which is exactly the desired behaviour we want. We don't want that you'll accidentally ovewrite changes from other peolpe by force pushing. So make a habit using only `--force-with-lease` instead of `--force` when force pushing.

#### Troubleshooting
Once you started a rebase you need to exit it manually either by working on it to completion, or by aborting it. To abort a rebase run
```shell
git rebase --abort
```
Make sure to abort your rebase before resetting your branch to origin if you want to do so.

In case you're unhappy with the squash or rebase changes, and you have your original unsquashed or unrebased branch in origin, you can always reset it to its origin state. Make sure you're not in rebase mode, and run:
```shell
git reset --hard origin/<your branch name>
```

**Warrnig:** The above command will delete local changes unrecoverably.
