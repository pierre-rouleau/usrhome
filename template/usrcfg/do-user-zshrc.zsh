# Sourced script: do-user-zshrc.zsh  -*- mode: sh; -*-
#
# Purpose   : Local setup.
# Created   : Sunday, March 31 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-04 08:13:04 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file is sourced by the usrhome/dot/zshrc.zsh file.
# It is meant to hold user-specific Z Shell configuration sourced each time a
# zsh shell starts as the ~/.zshrc does.
#
# - It participate in USRHOME configuration file tracing if it is activated.
# - It holds user-specific zsh configuration code in the user-specific section.
# - If a usrcfg/node/do-NODE-zshrc.zsh file exists it is sourced.
#   In the file name, NODE is the string returned by `hostname -s`.
#   - This way it is possible to store node-specific configuration in files
#     that can be committed into a (D)VCS and distributed in all nodes.
#
# The logic placed inside this file should conform to Z Shell syntax and
# capabilities.

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
#
# Trace if requested by user.
#
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"

# Source User's common shell logic.
. "$USRHOME_DIR_USRCFG/do-user.sh"

# ----------------------------------------------------------------------------
# User-Specific code  - MODIFY TO YOUR NEEDS
# ------------------
#
# Place your Z Shell specific code inside this section before the next
#  separator line.
# [HERE]








# ----------------------------------------------------------------------------
# USRHOME-specific Code
# ---------------------
#
# Topic: Node-specific configuration: zshrc
# -----------------------------------------
#
# Source the node-specific logic if the file exists
#
node="$(hostname -s)"
node_fname="$USRHOME_DIR_USRCFG/node/do-${node}-zshrc.zsh"
if [ -e "$node_fname" ]; then
    . "$node_fname"
fi
unset node
unset node_fname

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
