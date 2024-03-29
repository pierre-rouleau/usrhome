# ZSH Config FILE: zprofile
#
# Purpose   : Z Shell Profile Configuration - Customize important envvar once.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-03-29 09:59:35 EDT, updated by Pierre Rouleau>
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
export DIR_USRHOME_USRCFG="$usrhome_parent/usrcfg"

# echo "script          : $script"
# echo "original_script : $original_script"
# echo "usrhome_parent  : $usrhome_parent"

# Import user configuration. Possibly defines:
# - USRHOME_TRACE_SHELL_CONFIG
# - USRHOME_USE_HOMEBREW
source "$DIR_USRHOME_USRCFG/setfor-zsh-config.zsh"

# ------------------------------------------
# Trace Execution of Z Shell configuration files if required
# ----------------------------------------------------------

if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
    echo "---: Running ~/.zprofile : [\$0 : $0], \$SHELL : $SHELL "
fi

# For testing:
alias s='echo \$0 : $0 , \$SHELL : $SHELL'

# ------------------------------------------
# Set Environment Variable that won't change
# ------------------------------------------
#
# The following environment variables are valid inside all zsh (sub-)shells
# and are not expected to change for any shell of any type when running
# on this computer.

export EDITOR='emacs -nw'

# ------------------------------------------
# Set User-specific Path
# ----------------------

# - ~/my/bin                                : Local commands
# - /opt/homebrew/opt/make/libexec/gnubin   : Homebrew GNU Make (the latest version)
# - /opt/homebrew/bin                       : Homebrew binaries
# - /opt/homebrew/sbin                      : Homebrew binaries
# - /opt/homebrew/opt/m4/bin                : Homebrew m4

# For Homebrew
if [[ "$USRHOME_USE_HOMEBREW" = "1" ]]; then
    export PATH=\
/opt/homebrew/opt/make/libexec/gnubin:\
/opt/homebrew/bin:\
/opt/homebrew/sbin:\
/opt/homebrew/opt/m4/bin:\
$PATH
fi

# For local binaries
# If a ~/bin exists it may override the URSHOME/bin files.

export PATH=$DIR_USRHOME/bin:$PATH
if [[ -d "$HOME/bin" ]]; then
    export PATH=$HOME/bin:$PATH
fi

# ------------------------------------------
# /users/roup/my/bin/showpath



# ----------------------------------------------------------------------------
