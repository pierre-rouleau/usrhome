# Sourced script: do-sanitize-path.posix.sh  -*- mode: sh; -*-
#
# Purpose   : Sanitize PATH-like variable.
# Created   : Saturday, November  7 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-08 12:55:44 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# NOTE: THIS FILE WILL BE REMOVE SOON.  IT'S ONLY KEPT FOR REFERENCE.
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#
# Define a POSIX-shell interface for sanitizing a path-like variable.
# Sourcing this file does not sanitize a variable.
#
# Usage after sourcing:
#   _usrhome_sanitize_path              # defaults to PATH
#   _usrhome_sanitize_path MANPATH
#   _usrhome_sanitize_path FOOPATH


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#


# ----------------------------------------------------------------------------
# Code
# ----
#
#

if [ -z "${USRHOME_DIR:-}" ] ||
   [ ! -r "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh" ]; then
    printf '%s\n' 'sanitize-path: shared core is missing or unreadable' >&2
    return 1
fi

. "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh" || return 1

_usrhome_sanitize_path() {
    if [ "$#" -gt 1 ]; then
        printf '%s\n' 'Usage: _usrhome_sanitize_path [VARIABLE_NAME]' >&2
        return 1
    fi

    # Default to PATH only when the argument is omitted.
    set -- "${1-PATH}"

    # Permit only portable shell variable names before using eval.
    case "$1" in
        ''|[0123456789]*|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]*)
            printf 'sanitize-path: invalid variable name: %s\n' "$1" >&2
            return 1
            ;;
    esac

    # Test whether the variable is set and writable. The assignment runs
    # in a subshell so a readonly error does not terminate the caller.
    if ! (eval '[ "${'"$1"'+x}" = x ] && '"$1"'=${'"$1"'}') 2>/dev/null; then
        printf 'sanitize-path: %s must be set and writable\n' "$1" >&2
        return 1
    fi

    # Read the variable into positional parameters. Only the validated name
    # is inserted into eval's command text; the value is expanded afterward.
    eval 'set -- "$1" "${'"$1"'}"'

    # The status suffix also preserves trailing newlines in the value.
    set -- "$1" "$2" "$(
        if _usrhome_sanitize_path_value "$2" "$1"; then
            printf '.0'
        else
            printf '.1'
        fi
    )"

    case "$3" in
        *.0) set -- "$1" "$2" "${3%.0}" ;;
        *)
            printf 'sanitize-path: could not sanitize %s\n' "$1" >&2
            return 1
            ;;
    esac

    # Assign and export in the current shell.
    if ! export "$1=$3"; then
        printf 'sanitize-path: could not export %s\n' "$1" >&2
        return 1
    fi

    if [ "$2" != "$3" ] &&
       [ "${SHELL_IS_INTERACTIVE:-}" = true ] &&
       [ "${TERM:-}" != dumb ]; then
        if command -v usrhome_print_warning >/dev/null 2>&1; then
            usrhome_print_warning "USRHOME has sanitized your $1."
        else
            printf 'USRHOME has sanitized your %s.\n' "$1" >&2
        fi

        if [ "${USRHOME_TRACE_SHELL_CONFIG:-}" = 1 ]; then
            printf 'Original %s: %s\nSanitized %s: %s\n' \
                "$1" "$2" "$1" "$3"
        fi
    fi

    return 0
}

# ----------------------------------------------------------------------------
