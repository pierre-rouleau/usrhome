# ZSH Config FILE: zprofile
#
# Purpose   : Z Shell Profile Configuration - Customize important envvar once.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-30 15:17:39 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zprofile symbolic link to this file.

#
# Z Shell User-specific profile
# Executed when: login shell starts.
#
# This file is sourced once in login shells.  It is also source once
# in the shells launched by macOS terminal because macOS treats the terminal
# shells like login shells that do not authenticate user.
#
# This file is NOT sourced by sub-shell nor scripts.

# ----------------------------------------------------------------------------
# Code
# ----

# Get user-specific configuration.
# --------------------------------
#
# Identify the path of the usrcfg directory by taking advantage that
# usrhome and usrcfg are llocated inside the same parent, and that
# this script is executed via a symbolic link.
#
script=${(%):-%x}
original_script=`readlink $script`
usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"

# echo "script          : $script"
# echo "original_script : $original_script"
# echo "usrhome_parent  : $usrhome_parent"

# Import user configuration. Possibly defines:
# - USRHOME_TRACE_SHELL_CONFIG
# - USRHOME_USE_HOMEBREW
source "$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"

# ------------------------------------------
# Trace Execution of Z Shell configuration files if required
# ----------------------------------------------------------

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Running ~/.zprofile : [\$0 : $0], \$SHELL : $SHELL "
fi

# For testing:
alias s='echo \$0 : $0 , \$SHELL : $SHELL'

# ----------------------------------------------------------------------------
# Set Environment Variable that won't change
# ------------------------------------------
#

# Set User-specific Path
# ----------------------
source "$USRHOME_DIR/ibin/setfor-path"

# ----------------------------------------------------------------------------
