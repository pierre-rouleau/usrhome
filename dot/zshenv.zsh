# ZSH Config FILE: zshenv
#
# Purpose   : Z Shell Environment Configuration - Always sourced
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-30 16:24:25 EDT, updated by Pierre Rouleau>
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
# Identify the path of the usrcfg directory by taking advantage that
# usrhome and usrcfg are llocated inside the same parent, and that
# this script is executed via a symbolic link.
#
script=${(%):-%x}
original_script=`readlink $script`
usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"

# Read user's USRHOME configuration
source "$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Running ~/.zshenv"
fi

# ----------------------------------------------------------------------------
