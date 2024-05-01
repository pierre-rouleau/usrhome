# Bash Configuration FILE: bashrc.bash
#
# Purpose   : ~/.bashrc Bash Configuration File - Always sourced.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, April  8 2024.
# Time-stamp: <2024-05-01 18:01:32 EDT, updated by Pierre Rouleau>
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
# source #1 (shown in diagram)
usrhome_trace_activation="$USRHOME_DIR_USRCFG/setfor-shell-tracing.sh"
if [ -e "$usrhome_trace_activation" ]; then
    # shellcheck disable=SC1090
    . "$usrhome_trace_activation"
else
    printf "***USRHOME ERROR!!*********************************************\n"
    printf "Cannot find the user's shell tracing configuration file!\n"
    printf " Expected filet: %s\n" "$usrhome_trace_activation"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/setfor-shell-tracing.sh"
    printf "***************************************************************\n"
fi
unset usrhome_trace_activation


# 3 - Define USRHOME shell tracing functions
# ------------------------------------------
# source #2 (shown in diagram)
# shellcheck disable=SC1091
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

# source #3 (shown in diagram)
# shellcheck disable=SC1091
. "$USRHOME_DIR/ibin/setfor-bash-alias"

# ----------------------------------------------------------------------------
if [ -z "$USRHOME__IN_LOGIN" ] || [ "$USRHOME_CONFIG_AT_LOGIN" = "1" ]; then

    # ----------------------------------------------------------------------------
    # Update Path in sub-shells if not already done
    # ---------------------------------------------
    # source #4 (shown in diagram)
    # shellcheck disable=SC1091
    . "$USRHOME_DIR/ibin/setfor-path"

    # ----------------------------------------------------------------------------
    # Sanitize PATH
    # -------------
    #
    # source #4a (not shown in the diagram)
    # shellcheck disable=SC1091
    . "$USRHOME_DIR/ibin/do-sanitize-path.sh"
fi

# ----------------------------------------------------------------------------
# Topic: Prompt control
# =====================
#
# Ref: Bash Prompt Escape Sequences:
#  See: https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
#
# \d - Current date
# \h - Host name (hostname -s)
# \H - host name (hostname)
# \j - number of jobs managed by the shell
# \s - the name of the shell : basename of $0
# \t - Current time - 24-hour HH:MM:SS
# \T - Current time - 12-hour HH:MM:SS
# \@ - Current time - 12-hour am/pm
# \u - User name
# \v - version of Bash
# \V Release of Bash, version + patchlevel
# \W - Current working directory (ie: Desktop/)
# \w - Current working directory, full path (ie: /Users/Admin/Desktop)
# \! - History number of this command
# \# - Command number of this command
# \\$ - if the effective uid is 0: #, otherwise $. NOTE: the \ has to be escaped for $
# \\ - a backslash
# \[ - Begin sequence of non-printing characters.  Could be used to embed terminal control sequence into the prompt.
# \] - End of sequence
#
# Setting Terminal title to TITLE===>:    "\e]2;TITLE\a"
# - TITLE can include prompt escape sequences shown above
# - USRHOME_TITLE_TEXT := text taken from set-title arguments,
#                 included inside TITLE within the escape sequence selected for the prompt.
#
# - The set-title() function set USRHOME_TITLE_TEXT from its arguments ("$*")
#   and then update the PS1 prompt variable to create a terminal title
#   that dynamically updates on each command (via the prompt).
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
#  - Magenta     : '\[\e[0;35m\]'
#  - End of Color: '\[\e[0m\]'

# We can also use the tput command, which allows
# putting the prompt in bold. tput sgr0 resets the coloring.
#
#
#
# The code provides 2 already defined prompt, selected by the value
# of USRHOME_PROMPT_MODEL

# PROMPT MODEL 1: very short. No color, no bolding, no logic.
USRHOME_BASH_PROMPT1=">\h@\d@\t[\w]\n>\\$ "


# PROMPT MODEL 2: With color, bolding and logic.
# shellcheck disable=SC2016
USRHOME_BASH_PROMPT2='$(\
ec=${?}; \
if [ ${ec} == 0 ]; then \
  echo -n "\[\e[0;32m\]"; \
else \
  echo -n "\[\e[0;31m\]"; \
fi; \
printf "\[$(tput bold)\]>%2X\[\e[0m\]\[$(tput sgr0)\],L${SHLVL},\[$(tput bold)\]" ${ec}; \
if [ "$USRHOME_PROMPT_SHOW_USR_HOST" = "1" ]; then \
  printf "\h@\u@\t[\w]\[$(tput sgr0)\]\n";  \
else \
  printf "\t[\w]\[$(tput sgr0)\]\n";  \
fi; \
if [ "$EUID" -ne 0 ]; then \
  if [ ${ec} == 0 ]; then \
    echo "\[\e[0;32m\]bash$\[\e[0m\]"; \
  else \
    echo "\[\e[0;31m\]bash$\[\e[0m\]"; \
  fi; \
else \
  echo "\[\e[0;35m\]\[$(tput bold)\]bash#\[$(tput sgr0)\]\[\e[0m\]"; \
fi;\
) '


# PROMPT MODEL 3: With bolding and logic, but no color unless in root.
# shellcheck disable=SC2016
USRHOME_BASH_PROMPT3='$(\
ec=${?}; \
printf "\[$(tput bold)\]>%2X\[\e[0m\]\[$(tput sgr0)\],L${SHLVL},\[$(tput bold)\]" ${ec}; \
if [ "$USRHOME_PROMPT_SHOW_USR_HOST" = "1" ]; then \
  printf "\h@\u@\t[\w]\[$(tput sgr0)\]\n";  \
else \
  printf "\t[\w]\[$(tput sgr0)\]\n";  \
fi; \
if [ "$EUID" -ne 0 ]; then \
  echo "\[$(tput bold)\]bash$\[$(tput sgr0)\]"; \
else \
  if [ ${ec} == 0 ]; then \
     echo "\[\e[0;35m\]\[$(tput bold)\]bash#\[$(tput sgr0)\]\[\e[0m\]"; \
  else \
     echo "\[\e[0;31m\]\[$(tput bold)\]bash#\[$(tput sgr0)\]\[\e[0m\]"; \
  fi; \
fi;\
) '


usrhome-select-bash-prompt()
{
    case $USRHOME_PROMPT_MODEL in
        0 )
        # No prompt identified by USRHOME
        # It can be set by "$USRHOME_DIR_USRCFG/do-user-bashrc.bash"
        # which could be the original users ~/.bashrc file.
        # If that is not set, the default bash prompt is used.
        ;;

        1)
            USRHOME_PROMPT_MODEL=1
            PS1=${USRHOME_BASH_PROMPT1}
            export PS1
            ;;

        3)
            USRHOME_PROMPT_MODEL=3
            PS1=${USRHOME_BASH_PROMPT3}
            # shellcheck disable=SC2090
            export PS1
            ;;

        2 | *)
            # default (also model 2).  Activates that explicitly.
            USRHOME_PROMPT_MODEL=2
            PS1=${USRHOME_BASH_PROMPT2}
            # shellcheck disable=SC2090
            export PS1
            ;;
    esac
}

# Activate selected prompt
usrhome-select-bash-prompt

# Cleanup
unset ec



# Topic: Title
# ------------

# Set terminal window title using current prompt when outside Emacs.
set-title()
{
    # Arguments: A list of words to use as title.
    #  - Accepts no argument: clears the title text section..
    #  - store into USRHOME_TITLE_TEXT as one shell 'word' string.
    USRHOME_TITLE_TEXT="$*"
    export USRHOME_TITLE_TEXT
    if [ -n "$SSHPASS" ]; then
        title_shell_depth="L${SHLVL}+"
    else
        title_shell_depth="L${SHLVL}"
    fi

    # Set the title by appending the title setting logic to the PS1.
    title="\e]2;$USRHOME_TITLE_TEXT (Bash \v: ${title_shell_depth}: \h:\w)\a"
    if [ -z "$INSIDE_EMACS" ]; then
        PS1=$PS1${title}
    fi

    # shellcheck disable=SC2090
    export PS1
}

# Activate dynamic tracking title as soon as Bash takes over.
# Use a empty default Title Text
set-title ""

# ----------------------------------------------------------------------------
# User Bash Specific Configuration
# --------------------------------

if [ -z "$USRHOME__IN_LOGIN" ] || [ "$USRHOME_CONFIG_AT_LOGIN" = "1" ]; then
    # ----------------------------------------------------------------------------
    # Source User Extra Bash Configuration if it exists
    # -------------------------------------------------
    # source #5 (shown in diagram)
    #
    # The user logic can override anything that was defined by the USRHOME logic.
    user_bashrc="$USRHOME_DIR_USRCFG/do-user-bashrc.bash"
    if [[ -f "$user_bashrc" ]]; then
        # shellcheck disable=SC1090
        . "$user_bashrc"
    fi
fi

# ----------------------------------------------------------------------------
# Cleanup
unset usrhome_parent
unset original_script
unset script

usrhome_trace_out
# ----------------------------------------------------------------------------
