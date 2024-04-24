# Sourced script: do-user-bashrc.bash  -*- mode: bash; -*-
#
# Purpose   : USRHOME template for user-specific Bash configuration.
# Created   : Monday, April 22 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-24 09:46:22 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file is sourced by the usrhome/dot/bashrc.bash file.
# It is meant to hold user-specific Bash configuration sourced each time a
# Bash shell starts as the ~/.bashrc does.
#
# - It participate in USRHOME configuration file tracing if it is activated.
# - It holds user-specific Bash configuration code in the user-specific section.
# - If a usrcfg/node/do-NODE-bashrc.bash file exists it is sourced.
#   In the file name, NODE is the string returned by `hostname -s`.
#   - This way it is possible to store node-specific configuration in files
#     that can be committed into a (D)VCS and distributed in all nodes.
#
# The logic placed inside this file should conform to Bash syntax and
# capabilities.

# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-bashrc.bash"

# ----------------------------------------------------------------------------
# User-Specific code
# ------------------
#
# Place your code inside this section before the next separator line.
#  [HERE]







# Source the node-specific logic if the file exists
# -------------------------------------------------
node="$(hostname -s)"
node-fname="$USRHOME_DIR_USRCFG/node/do-${node}-bashrc.bash"
if [ -e "$node_fname" ]; then
    . "$node_fname"
fi
unset node
unset node_fname

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# -----------------------------------------------------------------------------
