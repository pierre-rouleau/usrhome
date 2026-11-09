# Sourced script: print-utilities.sh  -*- mode: sh; -*-
#
# Purpose   : Define usrhome printing functions.
# Created   : Monday, November  9 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-09 12:24:40 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Topic: USRHOME Print Functions
# ------------------------------

# All print functions refrain from printing on a dumb shell to reduce output
# on shells used by Emacs Tramp.

# - usrhome_printf         FORMAT ARGS...
# - usrhome_printf_warning FORMAT ARGS...
# - usrhome_printf_error   FORMAT ARGS...
# - usrhome_print_warning  TEXT
# - usrhome_print_error    TEXT
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

usrhome_printf()
{
    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@"
    fi
}

usrhome_printf_stderr()
{
    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
    fi
}

usrhome_printf_warning()
{
    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        _usrhome_MAGENTA='\033[0;35m' # magenta
        _usrhome_NC='\033[0m' # No Color
        printf -- '%b** WARNING ' "${_usrhome_MAGENTA}" >&2
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
        printf -- '%b' "${_usrhome_NC}" >&2
        unset _usrhome_MAGENTA _usrhome_NC
    fi
}

usrhome_printf_error()
{
    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        _usrhome_RED='\033[1;31m' # Bold red
        _usrhome_NC='\033[0m' # No Color
        printf -- '%b** ERROR ' "${_usrhome_RED}" >&2
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
        printf -- '%b' "${_usrhome_NC}" >&2
        unset _usrhome_RED _usrhome_NC
    fi
}


usrhome_print_error()
{
    # Arg: $1
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        # Print Arg text after **ERROR: prefix in red unless TERM=dumb
        _usrhome_RED='\033[1;31m' # Bold red
        _usrhome_NC='\033[0m' # No Color
        printf "${_usrhome_RED}** ERROR: %s${_usrhome_NC}\n" "$1" >&2
        unset _usrhome_RED _usrhome_NC
    fi
}

usrhome_print_warning()
{
    # Arg: $1
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        _usrhome_MAGENTA='\033[0;35m' # magenta
        _usrhome_NC='\033[0m' # No Color
        printf "${_usrhome_MAGENTA}** WARNING: %s${_usrhome_NC}\n" "$1" >&2
        unset _usrhome_MAGENTA _usrhome_NC
    fi
}

# ----------------------------------------------------------------------------
