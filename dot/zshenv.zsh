# ZSH Config FILE: zshenv
#
# Purpose   : Z Shell Environment Configuration - Always sourced
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-30 10:36:39 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zshenv symbolic link to this file.
#
# This is currently empty.  I sometimes activate the echo line to check where
# this is sourced.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
# Un-comment the following lines to trace sourcing of each of the
# Z shell configuration file:
echo $PATH
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
    echo "---: Running ~/.zshenv"
fi

# ----------------------------------------------------------------------------
