# Sourced script: do-user-zprofile.zsh  -*- mode: sh; -*-
#
# Purpose   : Template that holds user-specific Z Shell logic invoked by ~/.zprofile
# Created   : Monday, April  1 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-04 08:14:16 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file hold the user-logic for what would be placed in the ~/.zprofile
# file.
#
# It contains some USRHOME-specific code and place for the user-specific
# logic.
#
# This file is often not required because the ~/.zprofile configuration
# is not always used.
#

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
#
# Trace if requested by user.
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-zprofile.zsh"
#
# ----------------------------------------------------------------------------
# User-Specific code - MODIFY TO YOUR NEEDS
# ------------------
#
# Place your Z Shell profile code inside this section before the next
# separator line.
# [HERE]



# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
