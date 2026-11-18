# SH Configuration FILE: profile.sh
# shellcheck shell=sh
#
# Purpose   : Bash ~/.profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-18 10:56:31 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file, normally identified by the ~/.profile symbolic link,
# is the POSIX profile configuration entry point.
#
# The current implementation is empty; USRHOME does not yet support
# adding user specific logic to it.  All it does is participate in the
# USRHOME configuration tracing.
#
# If you need something done by ~/.profile on your system, write your own
# ~/.profile and do not symlink to here.

# Dependencies
# ------------
#
# - readlink

# ----------------------------------------------------------------------------
# USRHOME-Specific Code
# ---------------------
#
#

# 0 - Check if shell is interactive
# ---------------------------------
case "$-" in
    *i*)
        SHELL_IS_INTERACTIVE=true
        ;;
    *)
        SHELL_IS_INTERACTIVE=false
        ;;
esac

# 1 - Set USRHOME_DIR and USRHOME_DIR_USRCFG
# ------------------------------------------
#
# Identify the path of the usrcfg directory by taking advantage that usrhome
# and usrcfg are located inside the same parent directory, and that this
# script is executed via a symbolic link.
#
# If it has already been done, as indicated by the existence of the
# USRHOME_DIR environment variable, then skip this part.
#
# The setup script links ~/.profile directly to an absolute
# usrhome/dot/profile.sh (this file!). usrcfg is a sibling of usrhome.
#
# Note:  readlink is specified by POSIX.1-2024, but not POSIX.1-2017
#        If it is missing in your system please install it.
if [ -z "${USRHOME_DIR-}" ]; then
    if ! command -v readlink >/dev/null 2>&1; then
        printf '%s\n' 'USRHOME: readlink is required to resolve ~/.profile.' >&2
        return 1
    fi
    if ! usrhome_profile=$(readlink "$HOME/.profile"); then
        printf '%s\n' 'USRHOME: cannot read the ~/.profile symlink.' >&2
        return 1
    fi
    case $usrhome_profile in
        /*/dot/profile.sh) ;;
        *)
            printf '%s\n' 'USRHOME: ~/.profile must link to an absolute usrhome/dot/profile.sh path.' >&2
            return 1
            ;;
    esac
    USRHOME_DIR=${usrhome_profile%/dot/profile.sh}
    USRHOME_DIR_USRCFG=${USRHOME_DIR%/*}/usrcfg
    export USRHOME_DIR USRHOME_DIR_USRCFG
    unset usrhome_profile
fi


# 2 - Determine User Shell Configuration
# --------------------------------------
#
usrhome_config="$USRHOME_DIR_USRCFG/setfor-all-config.sh"
if [ -e "$usrhome_config" ]; then
    # shellcheck disable=SC1090
    . "$usrhome_config"
else
    if [ "$SHELL_IS_INTERACTIVE" = "true" ]; then
        printf "***USRHOME ERROR!!*********************************************\n"
        printf "Cannot find the user's configuration file!\n"
        printf " Expected file: %s\n" "$usrhome_config"
        printf " Please write it, use the template example as basis.\n"
        printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/setfor-all-config.sh"
        printf "***************************************************************\n"
    fi

fi
unset usrhome_config

# 3 - Trace Shell Configuration if required
# -----------------------------------------
#
# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
if [ -n "$USRHOME_TRACE_LEVEL" ]; then
    unset USRHOME_TRACE_LEVEL
fi
# shellcheck disable=SC2088
usrhome_trace_in "~/.profile   --> \$USRHOME_DIR/dot/profile.sh"

# ----------------------------------------------------------------------------
# User-Specific Logic
# -------------------
#
# [:todo 2024-05-01, by Pierre Rouleau:  Add ability to source usrcfg file if it exists.
#   The name of that file would probably be usrcfg/do-user-profile.sh
#   When adding it, the diagram must also be updated.
# ]

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: sh
# End:
