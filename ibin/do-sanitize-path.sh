# Sourced script: do-sanitize-path.sh  -*- mode: sh; -*-
#
# Purpose   : Sanitize current shell PATH.
# Created   : Saturday, April  6 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-07 15:14:34 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize the current shell's PATH
# - Replace '::' by ':'
# - Remove duplicate entries in the PATH, leave first one seen.
# - Remove any trailing ':'
# - Remove leading whitespace
#
# BUGS: Does not check if specified directories are present.
#       TODO: to be done later.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#

# ----------------------------------------------------------------------------
# Code
# ----
#
#

# Legacy entry point: always sanitize PATH.

if [ -n "${BASH_VERSION:-}" ]; then
    # shellcheck disable=SC1091 # fail to identify file
    . "${USRHOME_DIR}/ibin/xtra/sanitize-path.bash" || return 1
    _usrhome_sanitize_path PATH
else
    # shellcheck disable=SC1091 # fail to identify file
    . "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh" || return 1

    _usrhome_sanitize_legacy_path() {
        if [ "${PATH+x}" != x ] || ! ( PATH=$PATH ) 2>/dev/null; then
            printf '%s\n' 'sanitize-path: PATH must be set and writable' >&2
            return 1
        fi

        # The sentinel preserves trailing newlines in the sanitized value.
        set -- "$PATH" "$(_usrhome_sanitize_path_value "$PATH" PATH; printf '.')"
        set -- "$1" "${2%.}"

        if [ "$1" != "$2" ] &&
           [ "${SHELL_IS_INTERACTIVE:-}" = true ] &&
           [ "${TERM:-}" != dumb ]; then
            if command -v usrhome_print_warning >/dev/null 2>&1; then
                usrhome_print_warning "USRHOME has sanitized your PATH."
            else
                printf '%s\n' 'USRHOME has sanitized your PATH.' >&2
            fi
            if [ "${USRHOME_TRACE_SHELL_CONFIG:-}" = 1 ]; then
                printf 'Original PATH: %s\nSanitized PATH: %s\n' "$1" "$2"
            fi
        fi
        export PATH="$2"
    }
    _usrhome_sanitize_legacy_path
fi


# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
