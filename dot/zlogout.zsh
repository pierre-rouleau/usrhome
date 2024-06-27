# ZSH Configuration FILE: zlogout
#
# Purpose   : Z Shell Logout Configuration - Sourced at logout
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-06-27 12:33:00 EDT, updated by Pierre Rouleau>
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

if [[ -z $USRHOME_DIR ]]; then
    # - Identify the name of what bash executed (that should be the ~/.zshenv symlink)
    script=${(%):-%x}
    # - Then identify the real file pointed by that symlink: it should be
    #   this file,the usrhome/dot/bashrc.bash, with the complete path.
    original_script=`readlink $script`
    # - Then identify the parent directory of the file, that's the parent
    #   of the usrcfg directory too.
    usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
    USRHOME_DIR="$usrhome_parent/usrhome"
fi

# Nothing else than supporting configuration tracing.

usrhome_trace_in "~/.zlogout  --> \$USRHOME_DIR/dot/zlogout.zsh"

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
