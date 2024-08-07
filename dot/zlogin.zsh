# ZSH Configuration FILE: zlogin
#
# Purpose   : Z Shell Login Configuration - Sourced at login
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-08-02 12:43:40 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zlogin symbolic link to this file.
#
# This is currently empty.  I sometimes activate the echo line to check where
# this is sourced.
#

# ----------------------------------------------------------------------------
# Code
# ----
#
# The zlogin is always sourced after the zprofile, so the USRHOME
# environment variables are always defined; no need to check.

usrhome_trace_in "~/.zlogin   --> \$USRHOME_DIR/dot/zlogin.zsh"

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
