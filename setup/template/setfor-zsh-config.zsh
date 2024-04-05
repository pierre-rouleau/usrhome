# Sourced script: setfor-zsh-config  -*- mode: sh; -*-
#
# Purpose   : Template for the Private USRHOME configuration for Z Shell.
# Created   : Tuesday, March 26 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-05 14:28:15 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# This file holds the persistent user settings for the Z Shell controlled by
# USRHOME.  This file is a *template* provided as an example.
#
# To use it with USRHOME you need to store a copy of that file (potentially
# modified to fit your needs) into a directory named usrcfg.  That directory
# must be a sibling to the usrhome directory; they must be located inside the
# same parent directory.
#
# The usrhome/setup/setup-usrhome script creates the directory and stores this
# file if you wish to use it.

# ----------------------------------------------------------------------------
# Code : modify it to suit your needs.
# ------------------------------------
#

export EDITOR='emacs -nw'


# Activation control.  Value 0 deactivate, 1: activates
# -----------------------------------------------------

# Activate to trace Z Shell configuration file sourced.
export USRHOME_TRACE_SHELL_CONFIG=0

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
echo "---: Sourcing usrcfg/setfor-zsh-config.zsh"
fi

# Activate whether Homebrew is used:
# - 1 to use Homebrew,
# - 0 (or not defined) to prevent using Homebrew.
export USRHOME_USE_HOMEBREW=1

# ----------------------------------------------------------------------------
# Activation Control that can be overridden in sub-shells
# -------------------------------------------------------

if [[ -z $USRHOME__USRCFG_SEEN ]]; then
    export USRHOME__USRCFG_SEEN=1

    # Set the persistent values of variables that can
    # be changed dynamically to modify behavior inside
    # sub-shells.

    # Activate display of user name and host name on the prompt.
    export USRHOME_PROMPT_SHOW_USR_HOST=1

    # Select prompt model.
    export USRHOME_PROMPT_MODEL=1
    # Prompt Models:
    # - 1 : original prompt. exit-code, 24-hour time, nesting level, [user@host] 2 or 3 path component [%#]
    #       Use RPROMPT for VCS info, but not inside Emacs.
    #       Prompt search regexp := '^>[0-9]+@.+[%#]'

    # - 2 : 2-line prompt.  Complete path and VCS info in right side.
    #       The second line is very minimal and has just a % or # followed by a space.
    #       Prompt search regexp := '^[%#]
fi

# ----------------------------------------------------------------------------
# Directory Identification
# ------------------------
#
# The following environment variables identify the location of 4 important
# directories:
#
export USRHOME_DIR_MY="$HOME/my"
export USRHOME_DIR_DV="$HOME/my/dv"
export USRHOME_DIR_PUB="$HOME/my/dvpub"
export USRHOME_DIR_PRIV="$HOME/my/dvpriv"

# The last one is USRHOME_DIR, which defines the root of the usrhome directory
# It is first set by execution of setup/setup-usrhome.
