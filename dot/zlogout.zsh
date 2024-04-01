# ZSH Config FILE: zlogout
#
# Purpose   : Z Shell Logout Configuration - Sourced at logout
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-04-01 09:41:29 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# This is currently empty.  I sometimes activate the echo line to check where
# this is sourced.
#
# To use it, create a ~/.zlogout symbolic link to this file.

# ----------------------------------------------------------------------------
# Code
# ----
#
# Nothing else than supporting configuration tracing.

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Sourcing ~/.zlogout"
fi

# ----------------------------------------------------------------------------
