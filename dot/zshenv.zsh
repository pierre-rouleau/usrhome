# ZSH Config FILE: zshenv
#
# Purpose   : Z Shell Environment Configuration - Always sourced
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-04-19 18:20:06 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zshenv symbolic link to this file.
#
# This is currently empty.  I sometimes activate the echo line to check where
# this is sourced.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
usrhome_trace_in()
{
    # Arg 1: string: trace text.  printed after the level.
    #                Something like:  ~/.zshenv   --> \$USRHOME_DIR/dot/zshenv.zsh
    #                            or:  \$USRHOME_DIR/ibin/envfor-usrhome

    local title
    title=$1
    if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
        if [ -z "$USRHOME_TRACE_LEVEL" ]; then
            USRHOME_TRACE_LEVEL=1
            export USRHOME_TRACE_LEVEL
        else
            USRHOME_TRACE_LEVEL=$(( USRHOME_TRACE_LEVEL + 1 ))
        fi
        printf "-%s-: Sourcing %s\n" "$USRHOME_TRACE_LEVEL"  "$title"
    fi
}

# Identify the path of the usrcfg directory by taking advantage that
# usrhome and usrcfg are llocated inside the same parent, and that
# this script is executed via a symbolic link.
#
script=${(%):-%x}
original_script=`readlink $script`
usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"

# Read user's USRHOME configuration
# It must be available. Otherwise USRHOME won't work properly.
usrhome_zsh_config="$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"
if [ ! -e $usrhome_zsh_config ]; then
    printf "ERROR: USRHOME cannot find zsh configuration file!\n"
    printf " It is expected at: %s\n" "$usrhome_zsh_config"
    printf " Please install it, use the template example as basis.\n"
else
    source "$usrhome_zsh_config"
fi
unset usrhome_zsh_config

# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
unset USRHOME_TRACE_LEVEL
usrhome_trace_in "~/.zshenv   --> \$USRHOME_DIR/dot/zshenv.zsh"

# cleanup
unset usrhome_parent
unset original_script
unset script

# ----------------------------------------------------------------------------
