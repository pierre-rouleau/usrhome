#!/bin/sh
# SH FILE: bash_profile.bash
#
# Purpose   : Bash ~/.bash_profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-12 11:25:56 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#
# On macos
# --------
#
# On macOS with Bash as the default shell, the ~/.bash_profile file is executed
# when Terminal starts.  The implementation should normally source the ~/.bashrc
# file.
#
# When a Bash sub-shell is started without any option it is started as an
# interactive, non-login shell and it only source the ~/.bashrc.
#
# - Logic stored only in the ~/.bash_profile will be processed only for login
#   shells.
# - Logic stored in ~/.bashrc is only be processed in interactive shells.
#
# On Linux
# --------
#
# On the various Linux distributions I tested so far, the ~/.profile file is
# not processed.
#
#
# With USRHOME
# ------------
#
# To simplify the implementation and support various macOS versions and Linux
# distributions, USRHOME design forces putting **all** Bash control logic
# inside  ~/.bashrc.  More precisely into the usrhome/dot/bashrc.bash file
# pointed to by the ~/.bashrc symlink.
#
# The file sets the usrhome_inside_bash_profile variable and then sources the
# $USRHOME_DIR/dot/bashrc.bash file as would most implementation would do.
# Then it unset the variable.  This way the other sourced files can detect if
# they are sourced during login.

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

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Sourcing ~/.bash_profile   --> \$USRHOME_DIR/dot/bash_profile.bash"
fi

# Mimic behaviour found on most Bash implementations:
# - The ~/.bash_profile sources ~/.bashrc if it exists.
#   - In the case of USRHOME implementation ~/.bashrc
#     does exists: it is implemented as usrhome/dot/bashrc.bash
#
# Set usrhome_inside_bash_profile variable to true; this can be used
# within usrhome/dot/bashrc.bash to determine if it is running during
# a login or not.

usrhome_inside_bash_profile=true
. $USRHOME_DIR/dot/bashrc.bash
unset usrhome_inside_bash_profile

# ----------------------------------------------------------------------------
