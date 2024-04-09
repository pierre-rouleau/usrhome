# Sourced script: do-user-zshrc.zsh  -*- mode: sh; -*-
#
# Purpose   : Local setup.
# Created   : Sunday, March 31 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-03 07:52:01 EDT, updated by Pierre Rouleau>
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
if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
echo "---: Sourcing \$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"
fi
#
#

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
