# Sourced script: do-sanitize-path-posix.sh  -*- mode: sh; -*-
#
# Purpose   : Sanitize PATH-like variable content.  POSIX- Compliant logic.
# Created   : Sunday, November 08 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-11 10:14:23 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Define the `_usrhome_sanitize_path' function to sanitize a set, writable,
# colon-separated scalar.  Sourcing this file does not change a variable.
#
# The `_usrhome_sanitize_path` accepts one, optional argument: the name
# of the PATH-like variable.  It defaults to PATH.
#
# `_usrhome_sanitize_path' provides special handling for MANPATH: it supports
# MANPATH with a leading colon, trailing colon or internal double colon to
# identify the location where a library directory sequence can be injected.
#
#
#   _usrhome_sanitize_path              # PATH
#   _usrhome_sanitize_path MANPATH
#   _usrhome_sanitize_path CPATH
#
# It returns:
# - 0  on success,
# - 1 on an invalid request or processing error, and
# - 2 when no directory remains.
#
# On status 2 the original value is unchanged.
#
# The function does not check that each directory exists and that each
# directory is valid and safe to use.  Therefore the caller must not treat an
# unchanged value as safe.
#
# The caller must supply an ordinary scalar or a supported path scalar.
# Shell-specific arrays, namerefs and other attributed variables are outside
# this interface. Successful calls export the selected variable.
#
# PATH sanitization rules
# -----------------------
#
# The cleanup does the following for the values of all PATH-like variables:
#
# - Remove leading whitespace from each entry before checking for duplicates.
# - Remove duplicate entries and keep the first occurrence.
# - Remove empty entries between directories.
# - Remove leading, trailing and multiple colons, leaving only colons between
#   directories.
#
# For MANPATH, accept a single colon, or keep exactly one original empty field
# if it is the only exception: a leading colon, a trailing colon, or an
# internal double colon.  Multiple empty fields, or a whitespace-only field,
# invalidate all exceptions.  An internal marker must still have retained
# directories on both sides.
#
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
#
# Path-like Variables
# -------------------
#
# - PATH is the most fundamental environment variable in operating systems
#   like Linux, macOS, and Windows. It contains a colon-separated
#   (semicolon-separated on Windows) list of directory paths that the system
#   searches, from left to right, to find executable files when you type a
#   command.
#
# - MANPATH: An ordered list of directories where the man command searches for
#   manual (man) pages.
#
# - LD_LIBRARY_PATH (or DYLD_LIBRARY_PATH on macOS): An ordered list of
#   directories where the dynamic linker/loader looks for shared libraries
#   (.so or .dylib files) at runtime before checking default system locations.
#
# - CDPATH: A colon-separated list of directories used as search paths by the
#   cd (change directory) shell command, letting you jump to subdirectories
#   inside those base paths from anywhere.
#
# - INFOPATH: A list of directories searched by the info command-line
#   documentation reader for Texinfo documents.
#
# - PKG_CONFIG_PATH: A list of directories where pkg-config looks for .pc
#   metadata files to find compiler and linker flags for development
#   libraries.
#
# - PYTHONPATH: A list of directory paths that the Python interpreter adds to
#   sys.path to look for imported modules and packages.
#
# - CLASSPATH: Used by Java to specify the locations of class files,
#   libraries, and archives (.jar files) for the Java Virtual Machine (JVM).
#
# - FPATH / FNDIR: Used by shells like Zsh and KornShell to locate
#   autoloadable shell functions.

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
# - _usrhome_sanitize_path()
#   - _usrhome_sanitize_path_value()

_usrhome_sanitize_path_value() (
    # Arg 1: envvar name
    # Arg 2: envvar value

    # A single colon represents the default MANPATH without explicit directories.
    if [ "$2" = MANPATH ] && [ "$1" = : ]; then
        printf -- '%s' ':'
        return $?
    fi

    # All temporary variables are confined to this subshell.
    _usp_rest=$1
    _usp_kind=none
    _usp_empty_count=0
    _usp_bad_field=0
    _usp_first_field=1

    # Inspect original MANPATH fields before trimming and deduplication.
    if [ "$2" = MANPATH ]; then
        while :; do
            _usp_field=${_usp_rest%%:*}
            _usp_trimmed=${_usp_field#"${_usp_field%%[![:space:]]*}"}
            case $_usp_rest in
                *:*) _usp_more=1 ;;
                *)   _usp_more=0 ;;
            esac

            if [ -z "$_usp_field" ]; then
                _usp_empty_count=$((_usp_empty_count + 1))
                if [ "$_usp_first_field" -eq 1 ]; then
                    _usp_kind=leading
                elif [ "$_usp_more" -eq 0 ]; then
                    _usp_kind=trailing
                else
                    _usp_kind=internal
                fi
            elif [ -z "$_usp_trimmed" ]; then
                _usp_bad_field=1
            fi

            [ "$_usp_more" -eq 1 ] || break
            _usp_rest=${_usp_rest#*:}
            _usp_first_field=0
        done

        if [ "$_usp_empty_count" -ne 1 ] || [ "$_usp_bad_field" -ne 0 ]; then
            _usp_kind=none
        fi
    fi

    _usp_rest=$1
    _usp_output=
    _usp_pending=0

    while :; do
        _usp_field=${_usp_rest%%:*}
        _usp_trimmed=${_usp_field#"${_usp_field%%[![:space:]]*}"}

        if [ -z "$_usp_field" ] && [ "$_usp_kind" = internal ]; then
            _usp_pending=1
        fi

        if [ -n "$_usp_trimmed" ]; then
            _usp_duplicate=0
            _usp_scan=$_usp_output
            while [ -n "$_usp_scan" ]; do
                _usp_previous=${_usp_scan%%:*}
                if [ "$_usp_previous" = "$_usp_trimmed" ]; then
                    _usp_duplicate=1
                    break
                fi
                case $_usp_scan in
                    *:*) _usp_scan=${_usp_scan#*:} ;;
                    *)   break ;;
                esac
            done

            if [ "$_usp_duplicate" -eq 0 ]; then
                if [ -n "$_usp_output" ]; then
                    _usp_output="${_usp_output}:"
                    if [ "$_usp_pending" -eq 1 ]; then
                        _usp_output="${_usp_output}:"
                        _usp_pending=0
                    fi
                fi
                _usp_output="${_usp_output}${_usp_trimmed}"
            fi
        fi

        case $_usp_rest in
            *:*) _usp_rest=${_usp_rest#*:} ;;
            *)   break ;;
        esac
    done

    if [ -n "$_usp_output" ]; then
        case $_usp_kind in
            leading)  _usp_output=":${_usp_output}" ;;
            trailing) _usp_output="${_usp_output}:" ;;
        esac
    fi
    printf -- '%s' "$_usp_output"
)

_usrhome_sanitize_path() {
    if [ "$#" -gt 1 ]; then
        usrhome_printf_error 'Usage: _usrhome_sanitize_path [VARIABLE_NAME]\n'
        return 1
    fi
    set -- "${1-PATH}"

    # Only the validated name, not its value, is inserted into eval text.
    case $1 in
        ''|[0123456789]*|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_]*)
            usrhome_printf_error 'sanitize-path: invalid variable name\n'
            return 1
            ;;
    esac

    # A readonly assignment can terminate a non-interactive shell.
    # Test it in a subshell, before assigning in the calling shell.
    if ! (eval '[ "${'"$1"'+x}" = x ] && '"$1"'=${'"$1"'}') 2>/dev/null; then
        usrhome_printf_error 'sanitize-path: %s must be set and writable\n' "$1"
        return 1
    fi

    # Keep the name and the original value in function positional parameters.
    eval 'set -- "$1" "${'"$1"'}"'

    # The status suffix also preserves trailing newlines.
    set -- "$1" "$2" "$(
        if _usrhome_sanitize_path_value "$2" "$1"; then
            printf -- '.0'
        else
            printf -- '.1'
        fi
    )"
    case $3 in
        *.0) set -- "$1" "$2" "${3%.0}" ;;
        *)
            usrhome_printf_error 'sanitize-path: could not process %s\n' "$1"
            return 1
            ;;
    esac

    # Do not export an empty result. The original value remains unchanged.
    if [ -z "$3" ]; then
        usrhome_printf_error 'sanitize-path: %s has no directories after cleanup\n' "$1"
        return 2
    fi

    # The assignment occurs in the calling shell.
    if ! export "$1=$3"; then
        usrhome_printf_error 'sanitize-path: could not export %s\n' "$1"
        return 1
    fi

    if [ "$2" != "$3" ] &&
       [ "${SHELL_IS_INTERACTIVE:-}" = true ] &&
       [ "${TERM:-}" != dumb ]; then
        usrhome_printf_warning 'USRHOME has sanitized your %s.
         Use showpath to display the new value of that envvar.\n' "$1"
    fi
    return 0
}

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
