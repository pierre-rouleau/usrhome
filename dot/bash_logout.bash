# Bash Configuration FILE: bash_login.bash
#
# Purpose   : Bash ~/.bash_logout Configuration File - Sourced in interactive logout shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-23 16:06:14 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Optional Bash Logout, used by creating a ~/.bash_logout symlink to this file.
#
# The content of this file should support several Linux distributions.
# It also supports macOS.
#
# If this content does NOT corresponds to what you need, leave the ~/.bash_logout
# untouched or create a symnlink to you files stored inside the usrcfg directory.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
# 1 - Set USRHOME_DIR and USRHOME_DIR_USRCFG
# ------------------------------------------
#
# Identify the path of the usrcfg directory by taking advantage that usrhome
# and usrcfg are located inside the same parent directory, and that this
# script is executed via a symbolic link.
#
# If it has already been done, as indicated by the existence of the
# USRHOME_DIR environment variable, then skip this part.
#
if [[ -z $USRHOME_DIR ]]; then
    # - Identify the name of what bash executed (that should be the ~/.zshenv symlink)
    script=${(%):-%x}
    # - Then identify the real file pointed by that symlink: it should be
    #   this file,the usrhome/dot/bashrc.bash, with the complete path.
    original_script=`readlink $script`
    # - Then identify the parent directory of the file, that's the parent
    #   of the usrcfg directory too.
    usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
    export USRHOME_DIR="$usrhome_parent/usrhome"
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"
fi

# 2 - Determine is shell tracing is activated
# -------------------------------------------
#
usrhome_trace_activation="$USRHOME_DIR_USRCFG/setfor-shell-tracing.sh"
if [ -e $usrhome_trace_activation ]; then
    . "$usrhome_trace_activation"
else
    printf "***USRHOME ERROR!!*********************************************\n"
    printf "Cannot find the user's shell tracing configuration file!\n"
    printf " Expected file: %s\n" "$usrhome_trace_activation"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/setfor-shell-tracing.sh"
    printf "***************************************************************\n"
fi
unset usrhome_trace_activation

# 3 - Define USRHOME shell tracing functions
# ------------------------------------------
. $USRHOME_DIR/dot/shell-tracing.sh

# 4 - Trace Shell Configuration if required
# -----------------------------------------
#
# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
if [ -n $USRHOME_TRACE_LEVEL ]; then
    unset USRHOME_TRACE_LEVEL
fi
usrhome_trace_in "~/.bash_logout   --> \$USRHOME_DIR/dot/bash_logout.bash"

# ----------------------------------------------------------------------------

if [ "$(uname)" = "Linux" ]; then
    # when leaving the console clear the screen to increase privacy
    if [ "$SHLVL" = 1 ]; then
        [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
    fi
fi

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
