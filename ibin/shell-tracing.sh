# Sourced script: shell-tracing.sh  -*- mode: sh; -*-
#
# Purpose   : Define shell tracing functions.
# Created   : Saturday, April 20 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-20 10:21:59 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# This script is meant to be sourced, ('included'), by other USRHOME and usrcfg
# scripts that want to print/trace their nested execution as controlled by the
# USRHOME_TRACE_SHELL_CONFIG environment variable.
#
# It defines 2 functions: one that must be called at the beginning of the
# script and one at the end.  All sourcing done by the script must be done
# between the 2 calls.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# The USRHOME_TRACE_SHELL_CONFIG environment variable must have already been
# defined.

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
        else
            USRHOME_TRACE_LEVEL=$(( USRHOME_TRACE_LEVEL + 1 ))
        fi
        printf -- "-%s-: Sourcing %s\n" "$USRHOME_TRACE_LEVEL"  "$title"
    fi
}

usrhome_trace_out()
{
    if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
        USRHOME_TRACE_LEVEL=$(( USRHOME_TRACE_LEVEL - 1 ))
    fi
}


# ----------------------------------------------------------------------------
