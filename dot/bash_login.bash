#!/bin/sh
# SH FILE: bash_login.bash
#
# Purpose   : Bash ~/.bash_login Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-20 10:16:43 EDT, updated by Pierre Rouleau>
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

if [[ -z "$USRHOME_DIR" ]]; then
    echo "USRHOME ERROR: environment variables not available!"
    echo "               Check your usrcfg  files!"
fi

. $USRHOME_DIR/dot/shell-tracing.sh
usrhome_trace_in "~/.bash_login   --> \$USRHOME_DIR/dot/bash_login.bash"


# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
