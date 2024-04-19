#!/bin/sh
# SH FILE: bashrc.bash
#
# Purpose   : Vash ~/.bashrc Configuration File.
# Created   : Monday, April  8 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-19 14:52:34 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#

# ----------------------------------------------------------------------------
# Code
# ----
#
#

# Check Environment Consistency and Support Tracing
# -------------------------------------------------
#
if [[ -z "$USRHOME_DIR" ]]; then
    echo "USRHOME ERROR: environment variables not available!"
    echo "               Check your usrcfg  files!"
fi

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Sourcing ~/.bashrc    --> \$USRHOME_DIR/dot/bashrc.bash"
fi

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
    cd /Volumes/$1
}

function cdh {
    cd $USRHOME_DIR_MY/$1
}

function cddv {
    cd $USRHOME_DIR_DV/$1
}

function cdpriv {
    cd $USRHOME_DIR_PRIV/$1
}

function cdpub {
    cd $USRHOME_DIR_PUB/$1
}

function mdd {
    # mdd: mkdir and cd
    #      If path has / in it, mkdir -p is used.
    if printf "%s" "$1" | grep "/" > /dev/null; then
        mkdir -pv "$1" || return 1
    else
        mkdir "$1" || return 1
    fi
    cd "$1"
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

# ----------------------------------------------------------------------------
# Source User Extra zshrc if it exists
# ------------------------------------
user_bashrc="$USRHOME_DIR_USRCFG/do-user-bashrc.bash"
if [[ -f "$user_bashrc" ]]; then
    source "$user_bashrc"
fi
# ----------------------------------------------------------------------------
