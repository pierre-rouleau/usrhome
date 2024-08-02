# ZSH Configuration FILE: zprofile
#
# Purpose   : Z Shell Profile Configuration - Customize important envvar once.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-08-02 12:44:01 EDT, updated by Pierre Rouleau>
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
# The file sets the USRHOME__IN_LOGIN to 1 to indicate the sourcing of the
# configuration file by a login shell.
#
# This file is NOT sourced by sub-shell nor scripts.

# ----------------------------------------------------------------------------
# Code
# ----

# Trace Execution of Z Shell configuration files if required
# ----------------------------------------------------------

usrhome_trace_in "~/.zprofile --> \$USRHOME_DIR/dot/zprofile.zsh : [\$0 : $0], \$SHELL : $SHELL"

# Inform other files the shell configuration is done during the setup of a login shell.
USRHOME__IN_LOGIN=1

# ----------------------------------------------------------------------------
# Set Environment Variable that won't change
# ------------------------------------------
#

# Set User-specific Path
# ----------------------
source "$USRHOME_DIR/ibin/setfor-path"

# ----------------------------------------------------------------------------
# Source User Extra zprofile if it exists
# ------------------------------------
user_zprofile="$USRHOME_DIR_USRCFG/do-user-zprofile.zsh"
if [[ -f "$user_zprofile" ]]; then
    source "$user_zprofile"
fi
unset user_zprofile

# ----------------------------------------------------------------------------
# Cleanup
unset USRHOME__IN_LOGIN
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
