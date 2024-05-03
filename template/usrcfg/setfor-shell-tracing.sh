# Sourced script: setfor-shell-tracing.sh  -*- mode: sh; -*-
#
# Purpose   : Activate/Deactivate USRHOME Shell Tracing.
# Created   : Monday, April 22 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-02 23:30:04 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Defines the value of USRHOME_TRACE_SHELL_CONFIG if it is not already
# defined.  A value of 1 activates USRHOME shell configuration tracing,
# any other value disables it.

# ----------------------------------------------------------------------------
# Code
# ----
#
# Topic: Shell Tracing Configuration
# ----------------------------------

# Activation control.
# -------------------
#
# USRHOME_TRACE_SHELL_CONFIG values:
#  0        : Disable tracing
#  1        : Enable tracing; only print on stdout
#  file name: print on stdout and append text to that file.
#           : IMPORTANT: - Do NOT use the tilde (~) in the file name,
#           :              use $HOME instead as ~ is not expanded in double quotes.
#           :            - The file name must be located in an existing directory.

if [ -z $USRHOME_TRACE_SHELL_CONFIG ]; then
    # De-activate shell tracing by default.
    # Change to 1 or a file name to activate.
    export USRHOME_TRACE_SHELL_CONFIG=0
fi


# If you want USRHOME configuration to be available at the login shell
# then set USRHOME_CONFIG_AT_LOGIN to 1.  Otherwise comment out the
# following line; removing the definition.
export USRHOME_CONFIG_AT_LOGIN=1

# ----------------------------------------------------------------------------
