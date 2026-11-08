# Sourced script: sanitize-path.bash  -*- mode: sh; -*-
#
# Purpose   : PATH sanitizer for Bash.
# Created   : Friday, November  6 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-08 12:57:41 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# NOTE: THIS FILE WILL BE REMOVE SOON.  IT'S ONLY KEPT FOR REFERENCE.
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize path variable - Bash compliant.
# Functions only. Sourcing this file does not sanitize a variable.
#

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# Bash 3.2.57 or later.  Available on macOS.

# ----------------------------------------------------------------------------
# Code
# ----
#
#

# shellcheck disable=SC1091 # fail to identify file
. "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh" || return 1

_usrhome_sanitize_path_validate() {
    # Accept only ordinary writable scalar variables.
    case "$(declare -p "$1" 2>/dev/null)" in
        "declare -- $1="*|"declare -x $1="*) ;;
        *) return 1 ;;
    esac

    [ "${!1+x}" = x ]
}

_usrhome_sanitize_path_read() {
    printf '%s' "${!1}"
}

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: bash
# End:
