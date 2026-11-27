# SH Configuration FILE: profile.sh
# shellcheck shell=sh
#
# Purpose   : ~/.profile - Sourced in login shell
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-27 17:07:56 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file, normally identified by the ~/.profile symbolic link,
# is the POSIX profile configuration entry point for login shells.
#
# It is used by the following shells:
#
# - ash (and BusyBox)
# - bash
# - dash
# - ksh
# - sh
#
#
#
# How the ~/.profile file is used:
# -------------------------------
#
# ===================== ================================= ==================================== ==============================================================
# Session Type          Triggered by                      ksh Behavior                         bash Behavior
# ===================== ================================= ==================================== ==============================================================
# Interactive Login     • SSH login                       1. /etc/profile                      1. /etc/profile
#                       • Text console (TTY) login        2. ~/.profile                        2. First found of: ~/.bash_profile, ~/.bash_login, or ~/.profile
#                       • ksh -l / bash -l                3. $ENV (~/.kshrc)                      (Does not read ~/.bashrc automatically)
#                       • macOS Terminal.app (default)
#
#
# Interactive Non-Login • Most Linux GUI terminals        1. /etc/ksh.kshrc (if compiled in)   1. /etc/bash.bashrc (distro-dependent)
#                         (GNOME Terminal, Alacritty,     2. $ENV (~/.kshrc)                   2. ~/.bashrc (Skips ~/.profile)
#                         etc.)                              Skips ~/.profile)
#                       • Typing ksh or bash inside
#                         an existing shell
#                       • tmux / screen
#
# Non-Interactive       • Running a script (./script.sh)  • ksh93: Reads nothing               • Reads $BASH_ENV (if set)
#                       • ssh host 'command'              • ksh88: Reads $ENV
# ===================== ================================= ==================================== ==============================================================
#
# The Z shell (zsh) does not use ~/.profile, it uses ~/.zprofile instead.
#
#
# Dependencies
# ------------
#
# - readlink

# ----------------------------------------------------------------------------
# USRHOME-Specific Code
# ---------------------
#
#

# 1 - Check if shell is interactive
# ---------------------------------
case "$-" in
    *i*)
        SHELL_IS_INTERACTIVE=true
        ;;
    *)
        SHELL_IS_INTERACTIVE=false
        ;;
esac

# Enable printing for a visible interactive session.
# Non-interactive descendants retain any inherited policy.
case $- in
    *i*)
        if [ -t 0 ] || [ -t 1 ] || [ -t 2 ]; then
            USRHOME_PRINT_ENABLED=1
            export USRHOME_PRINT_ENABLED
        fi
        ;;
esac

# ----------------------------------------------------------------------------
# 2 - Set ENV to ~/.kshrc for all Korn shells
# -------------------------------------------
#
# The modern Korn shell implementation, ksh93, hard-codes the ENV environment
# to the path of the executable: ~/.kshrc and the systems are supposed to
# honour this convention, allowing a system to override ENV value to another
# executable file.  Unfortunately not all implementation hard-codes ENV:
#
#  ksh88, pdksh, and mksh do NOT set a default ENV value in their C source
#  code — only ksh93 (AT&T ksh93 and its ksh93u+m fork) hardcodes $HOME/.kshrc
#  as the fallback ENV path in C.
#
# Since this file can be used by non-Korn shells, see description earlier in
# this file, this code sets ENV for all instances of Korn shells.
#
#
# To detect any Korn shell variant (ksh93, mksh, pdksh, ksh88) in POSIX sh:
#
#  Because ksh88 does not set $KSH_VERSION, relying on $KSH_VERSION alone
#  misses legacy enterprise Korn shells. Combining $KSH_VERSION with $0 (the
#  shell's invocation name) and $ERRNO (a classic ksh88 indicator) covers all
#  bases safely.
#
#  $ERRNO is only needed when ksh88 is invoked under a generic name like
#  /bin/sh or -sh (which happens on older Solaris or AIX systems where /bin/sh
#  or /usr/xpg4/bin/sh is ksh88 under the hood, so $0 is sh or -sh instead of
#  ksh).

_usrhome_is_ksh=0
if [ -n "${KSH_VERSION:-}" ]; then
    # Matches ksh93, mksh, and pdksh
    _usrhome_is_ksh=1
elif [ -z "${BASH_VERSION:-}" ] && [ -z "${ZSH_VERSION:-}" ]; then
    # Fallback for legacy ksh88 (which lacks $KSH_VERSION)
    case "${0##*/}" in
        ksh|ksh88|rksh|-ksh|-ksh88|-rksh)
            _usrhome_is_ksh=1
            ;;
        sh|-sh)
            # Catch legacy ksh88 invoked as /bin/sh (e.g., Solaris /usr/xpg4/bin/sh)
            # In ksh88, ERRNO is an internal magic variable (defaults to 0); in dash/ash it is unset
            [ -n "${ERRNO:-}" ] && _usrhome_is_ksh=1
            ;;
    esac
fi
#
# Setting ENV for Korn shell it is strictly required for mksh (on
# Linux/Android) and pdksh (on OpenBSD/NetBSD) to load ~/.kshrc at all.
#
if [ "$_usrhome_is_ksh" -eq 1 ]; then
    ENV="${HOME}/.kshrc"
    export ENV
fi
unset _usrhome_is_ksh

# ----------------------------------------------------------------------------
# 3 - Set USRHOME_DIR and USRHOME_DIR_USRCFG
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

# ----------------------------------------------------------------------------
# 4 - Determine User Shell Configuration
# --------------------------------------
#
usrhome_config="$USRHOME_DIR_USRCFG/setfor-all-config.sh"
if [ -e "$usrhome_config" ]; then
    # shellcheck disable=SC1090
    . "$usrhome_config"
else
    if [ "$SHELL_IS_INTERACTIVE" = "true" ]; then
        # shellcheck source=../ibin/xtra/print-utilities.sh
        . "$USRHOME_DIR/ibin/xtra/print-utilities.sh"
        usrhome_printf_error "Cannot find the user's configuration file!
\t Expected file: %s
\t Please write it, use the template example as basis.
\t The template is: %s\n" "$usrhome_config" "$USRHOME_DIR/template/usrcfg/setfor-all-config.sh"
    fi
fi
unset usrhome_config

# ----------------------------------------------------------------------------
# 5 - Trace Shell Configuration if required
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
# 6 - User-Specific Logic
# -----------------------
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
