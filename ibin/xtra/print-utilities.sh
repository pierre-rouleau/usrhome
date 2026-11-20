# Sourced script: print-utilities.sh  -*- mode: sh; -*-
# shellcheck shell=sh
#
# Purpose   : Define usrhome printing functions.
# Created   : Monday, November  9 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-20 13:39:08 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Topic: USRHOME Print Functions
# ------------------------------

# All print functions refrain from printing on a dumb shell to reduce output
# on shells used by Emacs Tramp.
#
# - usrhome_printf         FORMAT ARGS...
# - usrhome_printf_stderr  FORMAT ARGS...
# - usrhome_printf_warning FORMAT ARGS...
# - usrhome_printf_error   FORMAT ARGS...
# - usrhome_print_warning  TEXT
# - usrhome_print_error    TEXT
#
#
# NOTE:
# All USRHOME code should use these functions to print information, status
# warning or error messages. The only code that should use printf directly
# is the code that prompts the user and the code that prints usage.
#
# The reason USRHOME uses the functions in this file to print is to ensure
# that USRHOME controlled shells that are not interactive print minimally so
# to help Emacs Tramp access these shells via SSH; a shell that prints too
# much starts slower and Emacs Tramp may fail to connect to it.
#
# For logic that prints into a pipe or into a file, then printf should be
# used.
#
# printf should always be preferred to echo: USRHOME should not use echo,
# except perhaps for quick debug printing that are commented out when
# committed.

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
    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi


    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$usrhome_print_is_allowed" = "true" ]; then
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@"
    fi
}

usrhome_printf_stderr()
{
    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi

    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$usrhome_print_is_allowed" = "true" ]; then
        if [ -t 2 ] || [ "$USRHOME_STDERR_PRINT_TO_PIPE" = "1" ]; then
            # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
            printf -- "$@" >&2
        fi
    fi
}

usrhome_printf_warning()
{
    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi

    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$usrhome_print_is_allowed" = "true" ]; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), allow printing the color.
            _usrhome_MAGENTA='\033[0;35m' # magenta
            _usrhome_NC='\033[0m' # No Color
            printf -- '%b*** WARNING %b' "${_usrhome_MAGENTA}" "${_usrhome_NC}" >&2
            # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
            printf -- "$@" >&2
            unset _usrhome_MAGENTA _usrhome_NC
        elif [ "$USRHOME_STDERR_PRINT_TO_PIPE" = "1" ]; then
            printf -- '*** WARNING ' >&2
            # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
            printf -- "$@" >&2
        fi
    fi
}

usrhome_printf_error()
{
    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi

    # Print text only when allowed.
    # All argument passed to printf.

    # Note: if SHELL_IS_INTERACTIVE is not set, then use as if it was set to "false".
    if [ "$usrhome_print_is_allowed" = "true" ]; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), allow printing the color.
            _usrhome_RED='\033[1;31m' # Bold red
            _usrhome_NC='\033[0m' # No Color
            printf -- '%b*** ERROR %b' "${_usrhome_RED}" "${_usrhome_NC}" >&2
            # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
            printf -- "$@" >&2
            unset _usrhome_RED _usrhome_NC
        elif [ "$USRHOME_STDERR_PRINT_TO_PIPE" = "1" ]; then
            printf -- '*** ERROR ' >&2
            # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
            printf -- "$@" >&2
        fi
    fi
}


usrhome_print_error()
{
    # Arg: $1

    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi


    if [ "$usrhome_print_is_allowed" = "true" ]; then
        # Print Arg text after **ERROR: prefix in red unless TERM=dumb
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), allow printing the color.
            _usrhome_RED='\033[1;31m' # Bold red
            _usrhome_NC='\033[0m' # No Color
            printf -- "${_usrhome_RED}** ERROR: ${_usrhome_NC}%s\n" "$1" >&2
            printf -- "** ERROR: %s\n" "$1" >&2
            unset _usrhome_RED _usrhome_NC
        elif [ "$USRHOME_STDERR_PRINT_TO_PIPE" = "1" ]; then
            printf -- "** ERROR: %s\n" "$1" >&2
        fi
    fi
}

usrhome_print_warning()
{
    # Arg: $1

    usrhome_print_is_allowed=false
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ -n "$TERM" ] && [ ! "$TERM" = "dumb" ]; then
        usrhome_print_is_allowed=true
    fi


    if [ "$usrhome_print_is_allowed" = "true" ]; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), allow printing the color.
            _usrhome_MAGENTA='\033[0;35m' # magenta
            _usrhome_NC='\033[0m' # No Color
            printf -- "${_usrhome_MAGENTA}** WARNING: ${_usrhome_NC}%s\n" "$1" >&2
            printf -- "** WARNING: %s\n" "$1" >&2
            unset _usrhome_MAGENTA _usrhome_NC
        elif [ "$USRHOME_STDERR_PRINT_TO_PIPE" = "1" ]; then
            printf -- "** WARNING: %s\n" "$1" >&2
        fi
    fi
}

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: sh
# End:
