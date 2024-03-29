# ZSH Config FILE: zshrc
#
# Purpose   : Z Shell Recource Configuration - Define alias, functions, prompt.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-29 17:44:33 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zshrc symbolic link to this file.

# User's Z Shell RC : ~/.zshrc
# Executed at: login, new interactive shell
# Note: This is re-executed in a sub-shell and inside a script.
#
# ----------------------------------------------------------------------------
# Code
# ----

# Setup Initial Environment if not already done
# ---------------------------------------------
#
# It's not done when the shell is a sub-shell.

if [[ -z "$USRHOME_DIR" ]]; then
    script=${(%):-%x}
    original_script=`readlink $script`
    usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"

    # echo "script          : $script"
    # echo "original_script : $original_script"
    # echo "usrhome_parent  : $usrhome_parent"

    # Import user configuration. Defines:
    # - USRHOME_TRACE_SHELL_CONFIG
    source "$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"
fi

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Running ~/.zshrc"
fi

# ----------------------------------------------------------------------------
# Set shortcut alias for Z shell
# ------------------------------
source $USRHOME_DIR/ibin/setfor-zsh-alias

# ------------------------------------------
# Set shortcut functions for Z shell
# ----------------------------------

function lsd {
    ls $1 -dGF *(/)
}

# lsl: list links
#  alias lsl='ls -lFGO *(@)'
# With a function it's possible to pass a command line argument (like lsl -l)
function lsl {
    ls $1 -FGO *(@)
}

function cdv {
    cd /Volumes/$1
}

function cdh {
    cd $USRHOME_DIR_MY/$1
}

function cddv {
    cd $USRHOME_DIR_DV/$1
}

function cddpriv {
    cd $USRHOME_DIR_PRIV/$1
}

function cddpub {
    cd $USRHOME_DIR_PUB/$1
}



# ------------------------------------------
# Update prompt
# -------------

# - Use PROMPT instead of PS1
# - Use RPROMPT to get a git status on the right side.

# It would be possible to display a prompmt on 2 lines with the following:
#     precmd() { print -rP "%B%? [%D{%H:%M:%S}] L:%L %n@%m:%~ %#%b " }
#     export PROMPT=""
#
# A new line can also be placed in the prompt with: $'\n'
# Both work but does not render properly inside Emacs pel-shell.
# It also prints the right side info on the second line.

# A better way is to display the path in the left side, but limited to the
# last 2 directory names in the path.  And then print the complete path inside
# the right side of the prompt, in bold, followed by a VCS status for Git.
# This way, on the left side prompt, I can print:
#
# - The value of last command exit code: %?
# - Time in 24-hour [hh:mm:ss] format:   [%D{%H:%M:%S}]
# - Shell nesting level:                 %L
# - User name                            %n
# - Host name                            %m
# - last 2 components of pwd             %2~
# - % for normal prompt, # for sudo      %#
# - all of the above in bold: %B ... %b

if [[ $USRHOME_PROMPT_SHOW_USR_HOST = 1 ]]; then
    export PROMPT=">%?@%B%D{%H:%M:%S} L%L %n@%m:%2~ %#%b "
else
    export PROMPT=">%?@%B%D{%H:%M:%S} L%L %3~%#%b "
fi

# Note that the prompt starts with a '>', the exit code and a '@'.  It is
# therefore possible to create a regexp that identifies a prompt line.
#
# That is useful inside Emacs (in pel-shell-prompt-line-regexp) and inside
# scripts that can identify consecutive prompts from a log and then compute
# the elapsed time for a given command.

if [ -z $INSIDE_EMACS ]; then
    # Unless inside Emacs, display full path at right
    # followed by Git information if inside a Git repo directory.
    # This is shown only if there is space in the window.
    # The info can be shown in term-mode but not in shell-mode (I don't know why).
    # Inside Emacs it's not that useful anyway because Emacs can display that information.
    autoload -Uz vcs_info
    precmd_vcs_info() { vcs_info }
    precmd_functions+=( precmd_vcs_info )
    setopt prompt_subst
    RPROMPT=%B%~%b\ \$vcs_info_msg_0_
    zstyle ':vcs_info:hg:*'  formats 'hg:%F{240}(%b)%r%f'
    zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
    zstyle ':vcs_info:*' enable hg git
fi

# ----------------------------------------------------------------------------
