# Sourced script: print-utilities.sh  -*- mode: sh; -*-
# shellcheck shell=sh
#
# Purpose   : Define usrhome printing functions.
# Created   : Monday, November  9 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-20 14:32:56 EST, updated by Pierre Rouleau>
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


# Return success when the session policy permits printing.
_usrhome_print_allowed()
{
    # return 0 when printing allowed

    [ "${USRHOME_PRINT_ENABLED-}" = 1 ] || return 1

    case ${TERM-} in
        '' | dumb) return 1 ;;
    esac

    return 0
}

# Return success when stderr is a terminal or the caller explicitly permits
# a non-terminal stderr destination.
_usrhome_stderr_allowed()
{
    # return 0 when printing allowed

    _usrhome_print_allowed || return 1
    [ -t 2 ] || [ "${USRHOME_STDERR_PRINT_TO_PIPE-}" = 1 ]
}

# --

usrhome_printf()
{
    [ "$#" -gt 0 ] || return 0

    # Print text only when allowed.
    # All argument passed to printf.

    if _usrhome_print_allowed; then
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@"
    fi
}

usrhome_printf_stderr()
{
    [ "$#" -gt 0 ] || return 0

    # Print text only when allowed.
    # All argument passed to printf.

    if _usrhome_stderr_allowed; then
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
    fi
}

usrhome_printf_warning()
{
    [ "$#" -gt 0 ] || return 0

    # Print text only when allowed.
    # All argument passed to printf.

    if _usrhome_stderr_allowed; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), print warning in magenta
            printf '\033[0;35m*** WARNING: \033[0m' >&2 || return
        else
            printf -- '*** WARNING: ' >&2
        fi
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
    fi
}

usrhome_printf_error()
{
    [ "$#" -gt 0 ] || return 0

    # Print text only when allowed.
    # All argument passed to printf.

    if _usrhome_stderr_allowed; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), print error in red
            printf '\033[1;31m*** ERROR: \033[0m  ' >&2 || return
        else
            printf -- '*** ERROR:   ' >&2
        fi
        # shellcheck disable=SC2059 # use the argument as the format string for maximum control.
        printf -- "$@" >&2
    fi
}


usrhome_print_error()
{
    [ "$#" -gt 0 ] || return 0

    # Arg: $1

     if _usrhome_stderr_allowed; then
         if [ -t 2 ]; then
             # If STDERR is connected to a terminal (as opposed to a pipe), print error in RED
             printf '\033[1;31m*** ERROR: \033[0m  %s\n' "${1-}" >&2
        else
            printf -- "*** ERROR:   %s\n" "$1" >&2
        fi
    fi
}

usrhome_print_warning()
{
    [ "$#" -gt 0 ] || return 0

    # Arg: $1

     if _usrhome_stderr_allowed; then
        if [ -t 2 ]; then
            # If STDERR is connected to a terminal (as opposed to a pipe), print warning in magenta
            printf '\033[0;35m*** WARNING: \033[0m%s\n' "${1-}" >&2
            unset _usrhome_MAGENTA _usrhome_NC
        else
            printf -- "*** WARNING: %s\n" "$1" >&2
        fi
    fi
}

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: sh
# End:
