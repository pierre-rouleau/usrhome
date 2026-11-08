# Sourced script: sanitize-path-core.sh  -*- mode: sh; -*-
#
# Purpose   : Core PATH-like variable sanitize logic.
# Created   : Friday, November  6 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-08 10:33:17 EST, updated by Pierre Rouleau>
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
# For MANPATH, keep exactly one original empty field if it is the only
# exception: a leading colon, a trailing colon, or an internal double colon.
# Multiple empty fields, or a whitespace-only field, invalidate all exceptions.
# An internal marker must still have retained directories on both sides.

# To clarify further by giving examples:
#
# - Valid PATH-like variable values:
#    - `/abc:/def/abc:/two`
#    - `/abc`
#    - `/abc/def:/def`
#  - Invalid PATH-like variable value and the corrected value:
#    - `:/abc`        ===> `/abc`
#    - `/abc:`        ===> `/abc`
#    - `/abc::/def`   ===> `/abc:/def`
#
# - Valid MANPATH values:
#   - `/abc`
#   -  `:/abc`
#   - `/abc:`
#   - `/abc::/def`
# - Invalid MANPATH value and the corrected value:
#   - `:/abc:`            ===> `/abc`
#   - `:/abc::/def`       ===>  `/abc:/def`
#   - `/abc::/def::/ghi`  ===> `/abc:/def:/ghi`
#   - `:/abc::/def:`      ===>  `/abc:/def`
#
# The goal being for MANPATH to only accept the leading or trailing colon or
# the internal double colon that identifies where the extra system PATH needs
# to be inserted.  Any other excessive colons would invalidate them all
# because it would not make sense to insert a set of directories in multiple
# locations and then we can consider the case as being an error or a speed or
# security issue.
#
# Also if removing leading spaces from directory causes colons to become
# adjacent to each other their presence should be considered as errors.  The
# following are invalid MANPATH values and their corrected values:

# - `:/abc:   /def`      ===> `:/abc:/def`
# - `/abc::   /def`      ===>  `/abc::/def`
# - `/abc:   :/def`      ===>   `/abc:/def`       Note here that the double
#                                                 colon was removed because it
#                                                 would have been created
#                                                 after the correction of
#                                                 removing spaces.
# - `/abc::/def:   /ghi` ===>  `/abc::/def:/ghi`  Note: here the double colon
#                                                 is retained because it was
#                                                 present in the original, and
#                                                 there were no other colon in
#                                                 excess just extra spaces
#                                                 inside another directory
#                                                 name.


# Functions only. Sourcing this file does not modify a path variable.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#

# ----------------------------------------------------------------------------
# Code
# ----
#
# This file provides the following functions.
# They are called from other files and have the following call hierarchy.
#
# - _usrhome_sanitize_path
#   - _usrhome_sanitize_path_value
#   - _usrhome_sanitize_path_check_result

_usrhome_sanitize_path_value() (
    # The subshell keeps these variables out of the calling shell.
    # Avoid 'local' so the entry point can also use this helper in any
    # POSIX shell.
    _uspv_rest=$1
    _uspv_target=$2
    _uspv_first=1
    _uspv_markers=0
    _uspv_invalid=0
    _uspv_marker=none

    # Inspect original fields before trimming or removing duplicates.
    if [ "$_uspv_target" = MANPATH ]; then
        while :; do
            _uspv_raw=${_uspv_rest%%:*}
            _uspv_entry=${_uspv_raw#"${_uspv_raw%%[![:space:]]*}"}
            case "$_uspv_rest" in
                *:*) _uspv_more=1 ;;
                *)   _uspv_more=0 ;;
            esac

            if [ -z "$_uspv_entry" ]; then
                if [ -n "$_uspv_raw" ]; then
                    # Removing whitespace here would create an empty field.
                    _uspv_invalid=1
                else
                    _uspv_markers=$((_uspv_markers + 1))
                    if [ "$_uspv_first" -eq 1 ]; then
                        _uspv_marker=leading
                    elif [ "$_uspv_more" -eq 0 ]; then
                        _uspv_marker=trailing
                    else
                        _uspv_marker=internal
                    fi
                fi
            fi
            [ "$_uspv_more" -eq 0 ] && break
            _uspv_rest=${_uspv_rest#*:}
            _uspv_first=0
        done
    fi

    if [ "$_uspv_markers" -ne 1 ] || [ "$_uspv_invalid" -ne 0 ]; then
        _uspv_marker=none
    fi

    _uspv_rest=$1
    _uspv_result=
    _uspv_first=1
    _uspv_pending=0

    while :; do
        _uspv_raw=${_uspv_rest%%:*}
        _uspv_entry=${_uspv_raw#"${_uspv_raw%%[![:space:]]*}"}
        _uspv_duplicate=0

        if [ -z "$_uspv_raw" ] && [ "$_uspv_marker" = internal ]; then
            _uspv_pending=1
        fi

        # Compare with previously retained entries.
        if [ -n "$_uspv_entry" ] && [ "$_uspv_first" -eq 0 ]; then
            _uspv_remaining=$_uspv_result
            while :; do
                _uspv_previous=${_uspv_remaining%%:*}
                if [ "$_uspv_previous" = "$_uspv_entry" ]; then
                    _uspv_duplicate=1
                    break
                fi
                case "$_uspv_remaining" in
                    *:*) _uspv_remaining=${_uspv_remaining#*:} ;;
                    *)   break ;;
                esac
            done
        fi

        if [ "$_uspv_duplicate" -eq 0 ] && [ -n "$_uspv_entry" ]; then
            if [ "$_uspv_first" -eq 0 ]; then
                _uspv_result="${_uspv_result}:"
                if [ "$_uspv_pending" -eq 1 ]; then
                    _uspv_result="${_uspv_result}:"
                    _uspv_pending=0
                fi
            fi
            _uspv_result="${_uspv_result}${_uspv_entry}"
            _uspv_first=0
        fi

        case "$_uspv_rest" in
            *:*) _uspv_rest=${_uspv_rest#*:} ;;
            *)   break ;;
        esac
    done

    # Do not preserve a marker if no directory remains.
    if [ -n "$_uspv_result" ]; then
        case "$_uspv_marker" in
            leading)  _uspv_result=":${_uspv_result}" ;;
            trailing) _uspv_result="${_uspv_result}:" ;;
        esac
    fi

    printf '%s' "$_uspv_result"
)

# An empty PATH can cause the shell to search the current directory.
_usrhome_sanitize_path_check_result() {
    if [ "$1" = PATH ] && [ -z "$2" ]; then
        if ! export PATH='/usr/bin:/bin'; then
            printf "sanitize-path: could not set fallback PATH\n" >&2
            return 1
        fi
        printf "sanitize-path: no PATH directories remain; using /usr/bin:/bin\n" >&2
        return 1
    fi
    return 0
}


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

    # Verify that we're not going to wipe the value of the path-like variable.
    _usrhome_sanitize_path_check_result "$1" "$3" || return 9

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
