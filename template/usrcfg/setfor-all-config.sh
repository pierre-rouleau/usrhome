# Sourced script: setfor-all-config.sh  -*- mode: sh; -*-
#
# Purpose   : Template for private USRHOME configuration command to Bash and Z Shell.
# Created   : Monday, April 22 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-02 17:25:33 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file holds persistent user settings that should apply to Bash as well
# as the Z Shell.  One part corresponds to what is required by USRHOME. The
# second part is for the user.
#
# This file is sourced by usrhome/ibin/setfor-path, which us sourced both by
# the USRHOME files for Bash and the Z Shell.

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
#
# Trace if requested by user.
usrhome_trace_in "\$USRHOME_DIR_USRCFG/setfor-all-config.sh"

# ----------------------------------------------------------------------------
# User-Specific code
# ------------------
#
# Place your code inside this section before the next separator line.
# Some code is already present and set the value of some USRHOME environment
# variables. You may keep this code or modify it as long as the values of
# these environment variables are set to something valid in your environment.

# ----------------------------------------------------------------------------
# Topic: Homebrew
# ---------------

# Activate whether Homebrew is used
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
# Topic: Concept Directory Identification
# ---------------------------------------
# The following environment variables identify the location of 4 important
# concept directories used by USRHOME.
#
# - Modify their values to suit your needs. You could also use logic to set
# - the values according to what system runs this code.

export USRHOME_DIR_MY="$HOME/my"
export USRHOME_DIR_DV="$HOME/my/dv"
export USRHOME_DIR_PUB="$HOME/my/dvpub"
export USRHOME_DIR_PRIV="$HOME/my/dvpriv"
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

    # Activate shell header display of path activations
    export USRHOME_SHOW_PATH_ACTIVATION=1

    # For USRHOME prompts: select whether host name and user name are shown
    #
    # Set the persistent values of variables that can be toggled dynamically.
    # Activate display of user name and host name on the prompt.
    export USRHOME_PROMPT_SHOW_USR_HOST=1

    # Select prompt model.
    # --------------------
    #
    # Example of logic to select the prompt.  MODIFY THIS TO YOUR NEEDS.
    #
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
            export USRHOME_PROMPT_MODEL=3
            ;;
    esac
fi

# ----------------------------------------------------------------------------
# cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
