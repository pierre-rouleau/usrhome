# Sourced script: setfor-shell-tracing.sh  -*- mode: sh; -*-
#
# Purpose   : Activate/Deactivate USRHOME Shell Tracing.
# Created   : Monday, April 22 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-25 08:47:00 EDT, updated by Pierre Rouleau>
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
#
# Activation control.  Value 0 deactivate, 1: activates
# -----------------------------------------------------

if [ -z $USRHOME_TRACE_SHELL_CONFIG ]; then
    # Activate (1) / de-activate (0) the tracing of Shell configuration
    # sourcing if the environment variable is not already set to a value (0, or 1).
    export USRHOME_TRACE_SHELL_CONFIG=0
fi


# If you want USRHOME configuration to be available at the login shell
# then set USRHOME_CONFIG_AT_LOGIN to 1.  Otherwise comment out the
# following line; removing the definition.
export USRHOME_CONFIG_AT_LOGIN=1

# ----------------------------------------------------------------------------
