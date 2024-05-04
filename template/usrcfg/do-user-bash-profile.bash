# Sourced script: do-user.zsh  -*- mode: bash; -*-
#
# Purpose   : USRHOME template of User-specific login bash configuration.
# Created   : Wednesday, April 24 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-04 08:27:06 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file is sourced by the usrhome/dot/bash_profile.bash file.
# It is meant to hold user-specific Bash configuration that must be executed
# once per login Bash shell.
#
# - It participate in USRHOME configuration file tracing if it is activated.
# - It holds user-specific Bash configuration code in the user-specific section.
# - If a usrcfg/node/do-NODE-bash_profile.bash file exists it is sourced.
#   In the file name, NODE is the string returned by `hostname -s`.
#   - This way it is possible to store node-specific configuration in files
#     that can be committed into a (D)VCS and distributed in all nodes.
#
# The logic placed inside this file should conform to Bash syntax and
# capabilities.

# ----------------------------------------------------------------------------
# USRHOME-specific Code
# ---------------------
#
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-bash_profile.bash"
# ----------------------------------------------------------------------------
# User-Specific code - MODIFY TO YOUR NEEDS
# ------------------
#
# Place your code inside this section before the next separator line.
#  [HERE]






# ----------------------------------------------------------------------------
# USRHOME-specific Code
# ---------------------
#
# Topic: Node-specific configuration: Bash Profile
# ------------------------------------------------
#
# Source the node-specific logic if the file exists
#
node="$(hostname -s)"
node_fname="$USRHOME_DIR_USRCFG/node/do-${node}-bash_profile.bash"
if [ -e "$node_fname" ]; then
    . "$node_fname"
fi
unset node
unset node_fname

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
