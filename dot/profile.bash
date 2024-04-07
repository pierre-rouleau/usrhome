#!/bin/sh
# SH FILE: profile.bash
#
# Purpose   : Bash ~/.profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-07 13:40:34 EDT, updated by Pierre Rouleau>
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

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Sourcing ~/.profile   --> \$USRHOME_DIR/dot/profile.bash"
fi

. "$HOME/.cargo/env"

# ----------------------------------------------------------------------------
