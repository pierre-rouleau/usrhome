# ZSH Config FILE: zlogout
#
# Purpose   : Z Shell Logout Configuration - Sourced at logout
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-30 10:33:12 EDT, updated by Pierre Rouleau>
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
#

if [[ -z "$USRHOME_DIR" ]]; then
    script=${(%):-%x}
    original_script=`readlink $script`
    usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
    usrhome_dir_usrcfg="$usrhome_parent/usrcfg"

    # Import user configuration. Defines:
    # - USRHOME_TRACE_SHELL_CONFIG
    source "$usrhome_dir_usrcfg/setfor-zsh-config.zsh"
fi

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Running ~/.zlogout"
fi

# ----------------------------------------------------------------------------
