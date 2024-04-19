# Sourced script: do-user-zshrc.zsh  -*- mode: sh; -*-
#
# Purpose   : Local setup.
# Created   : Sunday, March 31 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-19 19:01:40 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#


# ----------------------------------------------------------------------------
# Code
# ----
#
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"

# Setting Environments
# --------------------
alias use-curl-hb='source $USRHOME_DIR_USRCFG/envfor-curl-hb'
alias use-rust='source $USRHOME_DIR_USRCFG/envfor-rust'


# My Extra Commands
# -----------------
alias cdlog-installs='cd ~/my/logs/install-logs'
alias cdbin='cd ~/my/bin'
alias cddoc='cd ~/Documents'

alias f-numbers='fd ".numbers$"'

# Permanent Shell Configuration
# -----------------------------
. "$USRHOME_DIR_USRCFG/envfor-rust"

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
