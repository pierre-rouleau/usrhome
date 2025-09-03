# Sourced script: setfor-all-config.sh  -*- mode: sh; -*-
#
# Purpose   : USRHOME template for user's startup configuration of Bash and Z Shell.
# Created   : Monday, April 22 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2025-09-03 16:33:13 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file holds persistent user settings that should apply to Bash as well
# as the Z Shell.  One part corresponds to what is required by USRHOME. The
# second part is for the user.
#
# Defines the value of USRHOME_TRACE_SHELL_CONFIG if it is not already
# defined.  A value of 1 activates USRHOME shell configuration tracing,
# any other value disables it.

# This file is sourced by the following USRHOME files to set values of
# important USRHOME environment variables:
#
# - usrhome/dot/bash_login.bash
# - usrhome/dot/bash_profile.bash
# - usrhome/dot/bashrc.bash
# - usrhome/dot/profile.sh
# - usrhome/dot/zshenv.zsh

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------


# Topic: Shell Tracing Configuration
# ----------------------------------

# Activation control.
# -------------------
#
# USRHOME_TRACE_SHELL_CONFIG values:
#  0        : Disable tracing
#  1        : Enable tracing; only print on stdout
#  file name: print on stdout and append text to that file.
#           : IMPORTANT: - Do NOT use the tilde (~) in the file name,
#           :              use $HOME instead as ~ is not expanded in double quotes.
#           :            - The file name must be located in an existing directory.

if [ -z "$USRHOME_TRACE_SHELL_CONFIG" ]; then
    # Activate (1) / de-activate (0) the tracing of Shell configuration
    # sourcing if the environment variable is not already set to a value (0, or 1).
    #export USRHOME_TRACE_SHELL_CONFIG="$HOME/tmp/shell-trace.txt"
    export USRHOME_TRACE_SHELL_CONFIG=1
fi

# Get definitions of usrhome_trace_in() and usrhome_trace_out()
. "$USRHOME_DIR/ibin/shell-tracing.sh"

# Trace if requested by user.
usrhome_trace_in "\$USRHOME_DIR_USRCFG/setfor-all-config.sh"

# ----------------------------------------------------------------------------
# Topic: Homebrew
# ---------------

# Activate whether Homebrew is used:
# - 1 to use Homebrew,
# - 0 (or not defined) to prevent using Homebrew.
os_type=$(uname)
case $os_type in
    'Darwin' )
        # On macOS, Homebrew is quite useful.
        export USRHOME_USE_HOMEBREW=1

        # Homebrew Google Analytics Disabling
        # -----------------------------------
        # Homebrew has started acquiring Google analytics with installations.
        # See https://docs.brew.sh/Analytics
        # They are disabled by default.  To allow them comment the next line.
        export HOMEBREW_NO_ANALYTICS=1
        ;;

    *)
        # on Linux, it's not used that often
        export USRHOME_USE_HOMEBREW=0
        ;;
esac
unset os_type

# ----------------------------------------------------------------------------
# Code : MODIFY IT TO SUIT YOUR NEEDS.
# ------------------------------------
#

# ----------------------------------------------------------------------------
# Topic: Concept Directory Identification
# ---------------------------------------
#
# The following environment variables identify the location of the important
# concept directories:
#
# - Modify their values to suit your needs. You could also use logic to set
# - the values according to what system runs this code.

export USRHOME_DIR_MY="$HOME/my"
export USRHOME_DIR_CONTRACT="$HOME/my/dvc"
export USRHOME_DIR_LOCAL="$HOME/my/dvl"
export USRHOME_DIR_PUBLIC="$HOME/my/dvp"
export USRHOME_DIR_OTHER="$HOME/my/dvo"
export USRHOME_DIR_LIC="$HOME/my/licences"
export USRHOME_DIR_LOG="$HOME/my/logs"
export USRHOME_DIR_TMP="$HOME/tmp"

# ----------------------------------------------------------------------------
# Topic: Prompt : Select Prompt Model
# -----------------------------------

if [ -z "$USRHOME__USRCFG_SEEN" ] || [ "$(id -u)" = 0 ]; then
    export USRHOME__USRCFG_SEEN=1

    # Set the persistent values of variables that can
    # be changed dynamically to modify behavior inside
    # sub-shells.

    # Activate shell header display of path activation
    export USRHOME_SHOW_PATH_ACTIVATION=1

    # For USRHOME prompts: select whether host name and user name are shown
    #
    # Set the persistent values of variables that can be toggled dynamically.
    # Activate display of user name and host name on the prompt.
    export USRHOME_PROMPT_SHOW_USR_HOST=1
fi

# Define USRHOME_PROMPT_MODEL unless there's a reason to skip it.
#   The reason would be that it was already defined and overridden
#   by the usrhome-prompt_model-to command .
if [ -z "$USRHOME_PROMPT_MODEL_OVERRIDE" ]; then
    # Select prompt model.
    # --------------------
    # Prompt Models:
    # - 0 : Make no selection: use what's defined by user selection.
    # - 1 : original prompt. exit-code, 24-hour time, nesting level, [user@host] 2 or 3 path component [%#]
    #       Use RPROMPT for VCS info, but not inside Emacs.
    #       Prompt search regexp := '^>[0-9]+@.+[%#]'
    # - 2 : 2-line prompt.  Complete path and VCS info in right side.
    #       The second line is very minimal and has just a % or # followed by a space.
    #       Prompt search regexp := '^[%#]
    #
    case $(hostname -s) in
        "kali-gnu-linux-2023" )
            # For Kali Linux use the prompt logic that was originally
            # located in ~/.zshrc and now in the do-usr-zshrc.zsh
            export USRHOME_PROMPT_MODEL=0
            ;;

        * )
            # Select model 2 for zsh and model 3 for Bash
            #
            # Set USRHOME_SHELL to zsh, bash or unknown
            #
            . "$USRHOME_DIR/ibin/which-shell"
            case "$USRHOME_SHELL" in
                bash)
                    export USRHOME_PROMPT_MODEL=3
                    ;;
                zsh)
                    export USRHOME_PROMPT_MODEL=2

                    ;;
                *)
                    export USRHOME_PROMPT_MODEL=2
                    ;;
            esac
            ;;
    esac
fi

# ----------------------------------------------------------------------------
# Topic: Path in Login Shell
# --------------------------
#
# Modified PATH in the Login shell?
#
# If you want USRHOME-controlled PATH  configuration to be available at the
# login shell then set USRHOME_CONFIG_AT_LOGIN to 1.  Otherwise comment out
# the following line; removing the definition: the login shell will use the
# unmodified system PATH.
#
# export USRHOME_CONFIG_AT_LOGIN=1

# ----------------------------------------------------------------------------
# cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
