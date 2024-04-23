# Sourced script: do-user-zshrc.zsh  -*- mode: sh; -*-
#
# Purpose   : Local setup.
# Created   : Sunday, March 31 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-23 10:44:01 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file holds user-specific Z Shell logic invoked by the ~/.zshrc
# file as controlled by USRHOME.
#
# It contains some USRHOME-specific code and place for the user-specific
# logic.

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
#
# Trace if requested by user.
#
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"

# ----------------------------------------------------------------------------
# User-Specific code
# ------------------
#
# Place your code inside this section before the next separator line.
# Some example code is left in comment.
#

# # Manual Command for Setting Environments
# # ----------------------------------------
# alias use-rust='source $USRHOME_DIR_USRCFG/ibin/envfor-rust'
#
#
# # My Extra Commands
# # -----------------
# alias cdbin='cd ~/my/bin'
# alias cddoc='cd ~/Documents'
#
#
# # Permanent Shell Configuration
# # -----------------------------
# . "$USRHOME_DIR_USRCFG/envfor-rust"

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
