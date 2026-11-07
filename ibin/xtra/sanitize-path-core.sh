# Sourced script: sanitize-path-core.sh  -*- mode: sh; -*-
#
# Purpose   : Core PATH-like variable sanitize logic.
# Created   : Friday, November  6 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-07 13:37:40 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#  This holds the logic of path environment variable cleanup.

# The cleanup does the following for the values of all PATH-like variables:
#
# - Remove leading whitespace from each entry before checking for duplicates.
# - Remove duplicate entries and keep the first occurrence.
# - Remove empty entries between directories.
# - Remove leading, trailing and multiple colons, leaving only colons between
#   directories.
#
# For MANPATH: the handling of colon differs from the above:
# - Keep leading colon if there is only one present,
# - keep trailing colon if there is only one present,
# - keep one instance of double colon between a set of directories
#   if there is only one set of double colons ('::') present between
#   directories,
# - keep one colon between other directories and remove all other colons in excess.

# Functions only. Sourcing this file does not modify a path variable.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#

# ----------------------------------------------------------------------------
# Code
# ----
#
#

_usrhome_sanitize_path_value() (
    # This function runs in a subshell. Its local variables cannot shadow the
    # target in the calling shell because the value is passed as an argument.
    local rest="$1" target="$2"
    local entry result="" remaining previous
    local first=1 duplicate

    while :; do
        entry=${rest%%:*}
        entry=${entry#"${entry%%[![:space:]]*}"}
        duplicate=0

        # Compare with previously retained entries.
        if [ -n "$entry" ] && [ "$first" -eq 0 ]; then
            remaining=$result
            while :; do
                previous=${remaining%%:*}
                if [ "$previous" = "$entry" ]; then
                    duplicate=1
                    break
                fi
                case "$remaining" in
                    *:*) remaining=${remaining#*:} ;;
                    *)   break ;;
                esac
            done
        fi

        if [ "$duplicate" -eq 0 ] && [ -n "$entry" ]; then
            if [ "$first" -eq 0 ]; then
                result="${result}:"
            fi
            result="${result}${entry}"
            first=0
        fi

        case "$rest" in
            *:*) rest=${rest#*:} ;;
            *)   break ;;
        esac
    done

    # Retain one trailing colon only if MANPATH originally ended with one.
    if [ "$target" = MANPATH ]; then
        case "$1" in
            *:) result="${result}:" ;;
        esac
    fi

    printf '%s' "$result"
)

_usrhome_sanitize_path() {
    if [ "$#" -gt 1 ]; then
        printf '%s\n' 'Usage: sanitize-path [VARIABLE_NAME]' >&2
        return 1
    fi

    # Use PATH only when the argument is omitted, not when it is empty.
    set -- "${1-PATH}"

    case "$1" in
        ''|[0-9]*|*[!a-zA-Z0-9_]*)
            printf 'sanitize-path: invalid variable name: %s\n' "$1" >&2
            return 1
            ;;
    esac

    if ! _usrhome_sanitize_path_validate "$1"; then
        printf 'sanitize-path: %s must be a set, writable scalar string\n' "$1" >&2
        return 1
    fi

    # The sentinel preserves trailing newlines through command substitution.
    set -- "$1" "$(_usrhome_sanitize_path_read "$1"; printf '.')"
    set -- "$1" "${2%.}"
    set -- "$1" "$2" "$(_usrhome_sanitize_path_value "$2" "$1"; printf '.')"
    set -- "$1" "$2" "${3%.}"

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

    export "$1=$3"
}

# ----------------------------------------------------------------------------
