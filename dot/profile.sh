# SH Configuration FILE: profile.sh
#
# Purpose   : Bash ~/.profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-23 15:10:54 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#


# ----------------------------------------------------------------------------
# Code
# ----
#
#

usrhome_trace_in "~/.profile   --> \$USRHOME_DIR/dot/profile.sh"

. "$HOME/.cargo/env"

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
