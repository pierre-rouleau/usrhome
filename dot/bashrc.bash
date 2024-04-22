# Bash Configuration FILE: bashrc.bash
#
# Purpose   : ~/.bashrc Bash Configuration File - Always sourced.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, April  8 2024.
# Time-stamp: <2024-04-22 14:37:40 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Entry point for the USRHOME control of the Bash shell.
#
# To use it, create a ~/.bashrc symbolic link to this file.
#
# It sets the important USRHOME environment variables, USRHOME_DIR and
# USRHOME_DIR_USRCFG, then sources the usrcfg/setfor-bash-config.bash, where
# the user must store it ZShell configuration logic.  It also participates in
# the tracing of the shell configuration if activated by the user's
# configuration.

# ----------------------------------------------------------------------------
# Code
# ----
#
# Set USRHOME_DIR and USRHOME_DIR_USRCFG
# --------------------------------------
#
# Identify the path of the usrcfg directory by taking advantage that usrhome
# and usrcfg are located inside the same parent directory, and that this
# script is executed via a symbolic link.
#
# If it has already been done, as indicated by the existence of the
# USRHOME_DIR environment variable, then skip this part.
#
echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 1"
if [[ -z $USRHOME_DIR ]]; then
    # - Identify the name of what bash executed (that should be the ~/.bashrc symlink)
    script=${BASH_SOURCE[0]}
    # - Then identify the real file pointed by that symlink: it should be
    #   this file,the usrhome/dot/bashrc.bash, with the complete path.
    original_script="$(readlink "$script")"
    # Then identify the parent directory of the file, that's the parent
    # of the usrcfg directory too.
    usrhome_parent="$(dirname "$(dirname "$(dirname "$original_script")")")"
    export USRHOME_DIR="$usrhome_parent/usrhome"
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"
fi

echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 2"
# Read user's USRHOME configuration files for Bash Shell
# ------------------------------------------------------
#
# These must be available. Otherwise USRHOME won't work properly.
# - 1: Get user's shell tracing activation
usrhome_trace_activation="$USRHOME_DIR_USRCFG/setfor-shell-tracing.sh"
if [ ! -e "$usrhome_trace_activation" ]; then
    printf "ERROR: USRHOME cannot find the user's shell tracing configuration file!\n"
    printf " It is expected at: %s\n" "$usrhome_trace_activation"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s/template/usrcfg/setfor-shell-tracing.sh\n" "$USRHOME_DIR"
else
    . "$usrhome_trace_activation"
fi
unset usrhome_trace_activation

#
# - 2: Define USRHOME shell tracing functions
. "$USRHOME_DIR/ibin/shell-tracing.sh"

echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 3"
#
# - 3: Trace Shell Configuration if required
# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
if [ -n "$USRHOME_TRACE_LEVEL" ]; then
    unset USRHOME_TRACE_LEVEL
fi
# shellcheck disable=SC2088
usrhome_trace_in "~/.bashrc    --> \$USRHOME_DIR/dot/bashrc.bash"

echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 4"
#
# - 4: Include user's Bash shell configuration logic.
usrhome_bash_config="$USRHOME_DIR_USRCFG/setfor-bash-config.bash"
if [ ! -e "$usrhome_bash_config" ]; then
    printf "ERROR: USRHOME cannot find the user's bash configuration file!\n"
    printf " It is expected at: %s\n" "$usrhome_bash_config"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s/template/usrcfg/setfor-bash-config.bash\n" "$USRHOME_DIR"
else
    . "$usrhome_bash_config"
fi
unset usrhome_bash_config

echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 5"

# ----------------------------------------------------------------------------
# Set shortcut alias for Z shell
# ------------------------------

source "$USRHOME_DIR/ibin/setfor-bash-alias"

# ------------------------------------------
# Set shortcut functions for Bash shell
# -------------------------------------

alias lsd='ls -F | grep -i / | sort -f | sed -e "s~/~~g" | column'

# lsl: list links
#  alias lsl='ls -lFGO *(@)'
# With a function it's possible to pass a command line argument (like lsl -l)
# function lsl {
#     ls $1 -FGO *(@)
# }

function cdv {
    cd "/Volumes/$1" || return 1
}

function cdh {
    cd "$USRHOME_DIR_MY/$1" || return 1
}

function cddv {
    cd "$USRHOME_DIR_DV/$1" || return 1
}

function cdpriv {
    cd "$USRHOME_DIR_PRIV/$1" || return 1
}

function cdpub {
    cd "$USRHOME_DIR_PUB/$1" || return 1
}

function mdd {
    # mdd: mkdir and cd
    #      If path has / in it, mkdir -p is used.
    if printf "%s" "$1" | grep "/" > /dev/null; then
        mkdir -pv "$1" || return 1
    else
        mkdir "$1" || return 1
    fi
    cd "$1" || return 1
}

# ----------------------------------------------------------------------------
# Prompt control
# ==============
#
# \d - Current date
# \h - Host name
# \t - Current time
# \# - Command number
# \u - User name
# \W - Current working directory (ie: Desktop/)
# \w - Current working directory, full path (ie: /Users/Admin/Desktop)
#
# \$(?) : delay execution of $? when PS1 is evaluated (at the prompt)
#         to show the exit code of the command that was just completed.
#
# Aside from the above codes, it's possible to colorize the prompt
# with ANSI sequence color codes
# (see https://en.wikipedia.org/wiki/ANSI_escape_code)
#
# For using this coloring method:
# \e[     - start color scheme
#   0;32  - color (green)
#   m     - end of color
# ...  prompt
# \e[m  - stop color scheme
#
# For example:
#
#  - Red         : '\[\e[0;31m\]'
#  - Green       : '\[\e[0;32m\]'
#  - End of Color: '\[\e[0m\]'

# We can also use the tput command, which allows
# putting the prompt in bold. tput sgr0 resets the coloring.
#
#
#
# The code provides 2 already defined prompt, selected by the value
# of USRHOME_PROMPT_MODEL

case $LOGNAME in
    root)
        pb1="#"
      ;;
    *)
        pb1="%"
      ;;
esac

prompt1=">\h@\d@\t[\w]\n>$pb1 "

if [ "$USRHOME_PROMPT_SHOW_USR_HOST" = 1 ]; then
    # shellcheck disable=SC2016
    prompt2='$(\
ec=${?}; \
if [ ${ec} == 0 ]; then echo -n "\[\e[0;32m\]"; else echo -n "\[\e[0;31m\]"; fi; \
printf ">%2X" ${ec}; \
echo -n "\[\e[0m\]"; \
echo -n ",L${SHLVL}," ; \
echo \[$(tput bold)\]\h@\u@\t[\w]\[$(tput sgr0)\]; \
if [ "$EUID" -ne 0 ]; then echo "bash%"; else echo "\[\e[0;31m\]bash#\[\e[0m\]"; fi;\
) '
else
    # shellcheck disable=SC2016,SC2089
    prompt2='$(\
ec=${?}; \
if [ ${ec} == 0 ]; then echo -n "\[\e[0;32m\]"; else echo -n "\[\e[0;31m\]"; fi; \
printf ">%2X" ${ec}; \
echo -n "\[\e[0m\]"; \
echo -n ",L${SHLVL}," ; \
echo \[$(tput bold)\]\t[\w]\[$(tput sgr0)\]; \
if [ "$EUID" -ne 0 ]; then echo "bash%"; else echo "\[\e[0;31m\]bash#\[\e[0m\]"; fi;\
) '
fi

case $USRHOME_PROMPT_MODEL in
    0 )
    # No prompt identified by USRHOME
    # It can be set by "$USRHOME_DIR_USRCFG/do-user-bashrc.bash"
    # which could be the original users ~/.bashrc file.
    # If that is not set, the default bash prompt is used.
    ;;

    1)
        PS1=${prompt1}
        export PS1
        ;;

    *)
        # default (also model 2)
        PS1=${prompt2}
        # shellcheck disable=SC2090
        export PS1
        ;;
esac

unset prompt1
unset prompt2

# ----------------------------------------------------------------------------
# Update Path in sub-shells if not already done
# ---------------------------------------------
if [[ -z "$USRHOME_PATH_SET" ]]; then
    source "$USRHOME_DIR/ibin/setfor-path"
fi

function usrhome-switch-path {
    oldp=$PATH
    export PATH="$USRHOME_ORIGINAL_PATH"
    export USRHOME_ORIGINAL_PATH="$oldp"
    if [[ "$USRHOME_SHOW_PATH_ACTIVATION" = "1" ]]; then
        echo "- Switch PATH with USRHOME_ORIGINAL_PATH"
    fi
    unset oldp
}

# ----------------------------------------------------------------------------
# Sanitize PATH
# -------------
#
source "$USRHOME_DIR/ibin/do-sanitize-path.sh"

echo "--> /Users/roup/my/dv/usrhome/dot/bashrc.bash 99"
# ----------------------------------------------------------------------------
# Source User Extra zshrc if it exists
# ------------------------------------
user_bashrc="$USRHOME_DIR_USRCFG/do-user-bashrc.bash"
if [[ -f "$user_bashrc" ]]; then
    source "$user_bashrc"
fi

# ----------------------------------------------------------------------------
# Cleanup
unset usrhome_parent
unset original_script
unset script

usrhome_trace_out
# ----------------------------------------------------------------------------
