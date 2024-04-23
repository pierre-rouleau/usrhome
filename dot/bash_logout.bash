# Bash Configuration FILE: bash_login.bash
#
# Purpose   : Bash ~/.bash_logout Configuration File - Sourced in interactive logout shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-23 15:09:51 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Optional Bash Logout.


# ----------------------------------------------------------------------------
# Code
# ----
#
#

if [[ -z "$USRHOME_DIR" ]]; then
    echo "USRHOME ERROR: environment variables not available!"
    echo "               Check your usrcfg files!"
fi

. $USRHOME_DIR/dot/shell-tracing.sh
usrhome_trace_in "~/.bash_logout   --> \$USRHOME_DIR/dot/bash_logout.bash"


# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
