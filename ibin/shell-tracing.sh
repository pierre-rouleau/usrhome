# Sourced script: shell-tracing.sh  -*- mode: sh; -*-
#
# Purpose   : Define shell tracing functions.
# Created   : Saturday, April 20 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-02 23:22:29 EDT, updated by Pierre Rouleau>
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
# Topic: Shell Tracing Functions

usrhome_trace_in()
{
    # Arg 1: string: trace text.  printed after the level.
    #                Something like:  ~/.zshenv   --> \$USRHOME_DIR/dot/zshenv.zsh
    #                            or:  \$USRHOME_DIR/ibin/envfor-usrhome

    # Check if tracing is allow, return right away if not.
    if [ -z "$USRHOME_TRACE_SHELL_CONFIG" ]; then
        return
    fi
    if [ "$USRHOME_TRACE_SHELL_CONFIG" = "0" ]; then
        return
    fi

    # Tracing is requested
    title="$1"

    # Set or increment trace level
    if [ -z "$USRHOME_TRACE_LEVEL" ]; then
        USRHOME_TRACE_LEVEL=1
    else
        USRHOME_TRACE_LEVEL=$(( USRHOME_TRACE_LEVEL + 1 ))
    fi

    case "$USRHOME_TRACE_SHELL_CONFIG" in
        1)
            # Tracing, output to stdout only.
            printf -- "-%s-: Sourcing %s\n" "$USRHOME_TRACE_LEVEL"  "$title"
            ;;
        *)
            # Tracing, output to stdout and append to file named by $USRHOME_TRACE_SHELL_CONFIG
            printf -- "-%s-: Sourcing %s\n" "$USRHOME_TRACE_LEVEL"  "$title" | tee -a "$USRHOME_TRACE_SHELL_CONFIG"
            ;;
    esac

}

usrhome_trace_out()
{
    if [ -z "$USRHOME_TRACE_SHELL_CONFIG" ]; then
        return
    fi
    if [ "$USRHOME_TRACE_SHELL_CONFIG" = "0" ]; then
        return
    fi


    # Tracing is requested

    case "$USRHOME_TRACE_SHELL_CONFIG" in
        1)
            # Don't trace exit on stdout. Too many details on the terminal.
            ;;
        *)
            # Tracing; output only to file named by $USRHOME_TRACE_SHELL_CONFIG
            printf -- "-%s-: Exiting\n" "$USRHOME_TRACE_LEVEL" >> "$USRHOME_TRACE_SHELL_CONFIG"
            ;;
    esac

    # Decrement trace level
    USRHOME_TRACE_LEVEL=$(( USRHOME_TRACE_LEVEL - 1 ))


}


# ----------------------------------------------------------------------------
