# Sourced script: do-user.zsh  -*- mode: sh; -*-
#
# Purpose   : User Configuration Common to all supported shells.
# Created   : Thursday, May  2 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2025-03-24 07:52:53 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file holds configuration logic common to Bash and Z shells.
# It is sourced by usrcfg/do-user-zshrc.zsh and usrcfg/do-user-bashrc.bash

# ----------------------------------------------------------------------------
# USRHOME-Specific Code
# ---------------------
#
usrhome_trace_in "\$USRHOME_DIR_USRCFG/do-user.sh"

# ----------------------------------------------------------------------------
# Setting Environments - MODIFY TO YOUR NEEDS
# --------------------
#
# For example, if you want to provide use commands for the use of a special
# curl or setting up the shell for Rust development, you could define these
# use commands as aliases to the corresponding scripts.  Those are also
# provided as templates.

# Topic: curl
alias use-curl-hb='source $USRHOME_DIR_USRCFG/ibin/envfor-curl-hb'


# Topic: Rust
alias use-rust='source $USRHOME_DIR_USRCFG/ibin/envfor-rust'


# ----------------------------------------------------------------------------
# Topic: Change Current Directory - MODIFY TO YOUR NEEDS
# -------------------------------
#
# You could also provide extra cd like commands here,
# with some limited to specific OS.

alias cdlog-installs='cd ~/my/logs/install-logs'

cdbin()
{
    # - Arg 1: optional sub-directory name
    cd "$HOME/my/bin/$1"
}

cddoc()
{
    # - Arg 1: optional sub-directory name
    cd "$HOME/Documents/$1"
}

# Topic: macOS Number
if [ "$(uname)" = "Darwin" ]; then
    alias f-numbers='fd ".numbers$"'
fi



# ----------------------------------------------------------------------------
# Topic: EDITOR - MODIFY TO YOUR NEEDS
# -------------
#
# Select the edit other programs will use.
export EDITOR='emacs -nw'



# ----------------------------------------------------------------------------
# Topic: Automatic Environment Setting - MODIFY TO YOUR NEEDS
# ------------------------------------
#
# If you want to automatically activate a environment inside your shells, like
# preparing all shells to support Rust development or use Emacs server as the
# man reader, you could un-comment the following lines and write new ones.
#
# . "$USRHOME_DIR_USRCFG/ibin/envfor-rust"
# . "$USRHOME_DIR/ibin/envfor-emacs-for-man" -s




# ----------------------------------------------------------------------------
# USRHOME-Specific Code
# ---------------------
## Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
