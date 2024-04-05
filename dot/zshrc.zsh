# ZSH Config FILE: zshrc
#
# Purpose   : Z Shell Recource Configuration - Define alias, functions, prompt.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-04-05 08:27:02 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zshrc symbolic link to this file.

# User's Z Shell RC : ~/.zshrc
# Executed at: login, new interactive shell
# Note: This is sourced: - when a terminal starts a new Z Shell
#                        - when a zsh sub-shell is started (manually or
#                          from an application)
#
# ----------------------------------------------------------------------------
# Code
# ----

# Check Environment Consistency and Support Tracing
# -------------------------------------------------
#
if [[ -z "$USRHOME_DIR" ]]; then
    echo "USRHOME ERROR: environment variables not available!"
    echo "               Check your usrcfg  files!"
fi

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Sourcing ~/.zshrc    --> \$USRHOME_DIR/dot/zshrc.zsh"
fi

# ----------------------------------------------------------------------------
# Set shortcut alias for Z shell
# ------------------------------
source $USRHOME_DIR/ibin/setfor-zsh-alias

# ----------------------------------------------------------------------------
# Activate the help for zsh builtins
# ----------------------------------
#
# The Z Shell has zsh builtin help inside a directory like the following:
#
# - Linux:  /usr/share/zsh/help
# - macOS:  /usr/share/zsh/VVV/help  , where VVV is zsh version number
#
# With zsh installed with Homebrew it might be /usr/local/share/help
#
# Unfortunately, by default, help does not work in zsh the way it does
# inside Bash. The Z Shell provides run-help but it is normally aliased
# to man and then you need to know which section of what man page to
# find the information about the Z shell builtin.
#
# The following activates a working help command for builtin inside the Z
# shell that works like the help in bash.
#
# 1 - HELPDIR:
#
# The following logic sets the HELPDIR environment variable to the
# path where the zsh files are stored, unless USRHOME_DIR_HELPDIR
# is set, in that case it uses that.
if [[ -n "$USRHOME_DIR_HELPDIR" ]]; then
    export HELPDIR="$USRHOME_DIR_HELPDIR"
else
    os_type=$(uname)
    case $os_type in
        'Darwin' )
            # The following works since at least OS/X Snow Leopard 10.6.8
            zsh_version=$(zsh --version | awk '{print $2}')
            export HELPDIR=/usr/share/zsh/${zsh_version}/help
            ;;

        *)
            # This works on Kali Linux, Ubuntu,
            export HELPDIR=/usr/share/zsh/help
            ;;
    esac
    unset os_type
fi
#
# 2 - Un-alias run-help and alias help to autoloaded run-help
unalias run-help 2> /dev/null
autoload run-help
alias help=run-help

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

function mdd {
    # mdd: mkdir and cd
    #      If path has / in it, mkdir -p is used.
    if echo "$1" | grep "/" > /dev/null; then
        mkdir -pv "$1" || return 1
    else
        mkdir "$1" | return 1
    fi
    cd "$1"
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

p1=$'>%?@%B%D{%H:%M:%S} L%L'

if [ $USRHOME_PROMPT_SHOW_USR_HOST = 1 ]; then
    p2=$'%n@%m:%~%b'
else
    p2=$'%~%b'
fi

case $USRHOME_PROMPT_MODEL in
    0 )
    # No prompt identified by USRHOME
    # It can be set by "$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"
    # which could be the original users ~/.zshrc
    # If not set, the default zsh prompt is used.
    ;;

    2 )
        autoload -Uz vcs_info
        precmd_vcs_info() { vcs_info }
        precmd_functions+=( precmd_vcs_info )
        setopt prompt_subst
        zstyle ':vcs_info:hg:*'  formats '%F{240}hg:(%b)%r%f'
        zstyle ':vcs_info:git:*' formats '%F{240}git:(%b)%r%f'
        zstyle ':vcs_info:*' enable hg git
        export PROMPT=$'$p1 $p2 \ \$vcs_info_msg_0_\n%B%#%b '

        # Show the exit code and the current sub-process jobs
        if [[ -z "$INSIDE_EMACS" ]]; then
            #          exit code: value x on failure  #jobs when more than 1
            RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
        fi
        ;;

    * )
        # Default (also model 1)
        export PROMPT=$'$p1 $p2 '

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
        ;;

esac

# ----------------------------------------------------------------------------
# Update Path in sub-shells if not already done
# ---------------------------------------------
if [[ -z "$USRHOME_PATH_SET" ]]; then
    source "$USRHOME_DIR/ibin/setfor-path"
fi

# ----------------------------------------------------------------------------
# Sanitize PATH
# -------------
#
# - Replace '::' by ':'
# - Remove duplicate entries in the PATH, leave first one seen.
# - Then remove the trailing ':' injected.
#
# If the old path had to be sanitized, display a warning
# describing the number of directory entries in each.
# Use xargs to remove leading spaces from the number strings.

path_entries="$(echo "$PATH" | tr ':' '\n' | wc -l | xargs)"
sanitized_path="$(echo "$PATH" | sed 's/::/:/g' | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':')"
if [[ "${sanitized_path:0-1}" = ":" ]]; then
    sanitized_path="${sanitized_path: 0:-1}"
fi

sanitized_path_entries="$(echo "$sanitized_path" | tr ':' '\n' | wc -l | xargs)"
if [[ "$path_entries" != "$sanitized_path_entries" ]]; then
    echo "WARNING: USRHOME has sanitized your PATH!"
    if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
        echo "         It had $path_entries directories, it now has $sanitized_path_entries."
        echo " The original PATH was:"
        showpath -n
    else
        echo "Set USRHOME_TRACE_SHELL_CONFIG to 1 in to see more info."
        echo "- Edit: \$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"
    fi
fi
export PATH=$sanitized_path

# ----------------------------------------------------------------------------
# Source User Extra zshrc if it exists
# ------------------------------------
user_zshrc="$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"
if [[ -f "$user_zshrc" ]]; then
    source "$user_zshrc"
fi
# ----------------------------------------------------------------------------
