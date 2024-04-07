#!/bin/sh
# SH FILE: bash_login.bash
#
# Purpose   : Bash ~/.bash_login Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-07 13:40:38 EDT, updated by Pierre Rouleau>
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
    echo "---: Sourcing ~/.bash_login   --> \$USRHOME_DIR/dot/bash_login.bash"
fi


# ----------------------------------------------------------------------------
