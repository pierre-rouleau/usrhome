# Sourced script: sanitize-path.zsh  -*- mode: sh; -*-
#
# Purpose   : PATH sanitizer for Zsh.
# Created   : Friday, November  6 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-06 18:17:58 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize path variable - Zsh compliant.
# Functions only. Sourcing this file does not sanitize a variable.
#

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#  Zsh shell.

# ----------------------------------------------------------------------------
# Code
# ----
#
#

. "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh"

_usrhome_sanitize_path_validate() {
    zmodload zsh/parameter || return 1
    [[ ${+parameters[$1]} -eq 1 ]] || return 1

    case "${parameters[$1]}" in
        *-readonly*)
            return 1
            ;;
        scalar|scalar-export)
            return 0
            ;;
        scalar-*)
            # Allow the special tied path parameters.
            case "$1" in
                PATH|MANPATH) return 0 ;;
            esac
            ;;
    esac
    return 1
}

_usrhome_sanitize_path_read() {
    printf '%s' "${(P)1}"
}

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
