# Bash Configuration FILE: bashrc.bash
#
# Purpose   : ~/.bashrc Bash Configuration File - Always sourced.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, April  8 2024.
# Time-stamp: <2024-04-22 21:58:37 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Entry point for the USRHOME control of the Bash shell.
#
# To use it, create a ~/.bashrc symbolic link to this file.
#
# - If not already done, sets the important USRHOME environment variables:
#   - USRHOME_DIR
#   - USRHOME_DIR_USRCFG
#
# - Determines if shell tracing is activated by sourcing user's controlled
#   file: usrcfg/setfor-shell-tracing.sh
#
# - Defines the USRHOME shell tracing functions by sourcing
#   file: usrhome/ibin/shell-tracing.sh
#
# - If required print tracing of this file.
#
# ----------------------------------------------------------------------------
# Code
# ----
#
# 1 - Set USRHOME_DIR and USRHOME_DIR_USRCFG
# ------------------------------------------
#
# Identify the path of the usrcfg directory by taking advantage that usrhome
# and usrcfg are located inside the same parent directory, and that this
# script is executed via a symbolic link.
#
# If it has already been done, as indicated by the existence of the
# USRHOME_DIR environment variable, then skip this part.
#
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


# 2 - Determine is shell tracing is activated
# -------------------------------------------
#
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


# 3 - Define USRHOME shell tracing functions
# ------------------------------------------
. "${USRHOME_DIR}/ibin/shell-tracing.sh"


# 4 - Trace Shell Configuration if required
# -----------------------------------------
#
# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
if [ -n "$USRHOME_TRACE_LEVEL" ]; then
    unset USRHOME_TRACE_LEVEL
fi
# shellcheck disable=SC2088
usrhome_trace_in "~/.bashrc    --> \$USRHOME_DIR/dot/bashrc.bash"

# ----------------------------------------------------------------------------
# Set shortcut aliases and short functions for Bash shell
# -------------------------------------------------------

source "$USRHOME_DIR/ibin/setfor-bash-alias"

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
. "$USRHOME_DIR/ibin/setfor-path"

# ----------------------------------------------------------------------------
# Sanitize PATH
# -------------
#
. "$USRHOME_DIR/ibin/do-sanitize-path.sh"

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
