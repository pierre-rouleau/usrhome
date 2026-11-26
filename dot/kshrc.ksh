# SH FILE: kshrc.ksh
# shellcheck shell=ksh
#
# Purpose   : ~/.kshrc file for USRHOME.
# Created   : Thursday, November 26 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-26 16:22:32 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# ~/.kshrc must be an absolute symlink to this file.
# This file is sourced by ksh; do not execute it directly.
#


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
#

# Do not initialize an interactive environment for ksh -E scripts.
case $- in
    *i*) ;;
    *) return 0 ;;
esac

# Match the existing Bash and Zsh behavior for Emacs Tramp.
if [ "${TERM-}" = dumb ] && [ -z "${INSIDE_EMACS-}" ]; then
    PS1='$ '
    return 0
fi

if [ -t 0 ] || [ -t 1 ] || [ -t 2 ]; then
    USRHOME_PRINT_ENABLED=1
    export USRHOME_PRINT_ENABLED
fi

# Derive the checkout from the installed symlink, not from an inherited
# USRHOME_DIR. The usrcfg directory is a sibling of the checkout.
if ! command -v readlink >/dev/null 2>&1; then
    printf '%s\n' 'USRHOME: readlink is required to resolve ~/.kshrc.' >&2
    return 1
fi

if ! _usrhome_kshrc_target=$(readlink "$HOME/.kshrc"); then
    printf '%s\n' 'USRHOME: cannot read the ~/.kshrc symlink.' >&2
    return 1
fi

case $_usrhome_kshrc_target in
    /*/dot/kshrc.ksh) ;;
    *)
        printf '%s\n' \
            'USRHOME: ~/.kshrc must link to an absolute usrhome/dot/kshrc.ksh path.' >&2
        unset _usrhome_kshrc_target
        return 1
        ;;
esac

USRHOME_DIR=${_usrhome_kshrc_target%/dot/kshrc.ksh}
USRHOME_DIR_USRCFG=${USRHOME_DIR%/*}/usrcfg
export USRHOME_DIR USRHOME_DIR_USRCFG
unset _usrhome_kshrc_target

# Load user settings and tracing functions in this shell.
_usrhome_kshrc_config=$USRHOME_DIR_USRCFG/setfor-all-config.sh
if [ ! -r "$_usrhome_kshrc_config" ]; then
    printf 'USRHOME: cannot read configuration: %s\n' \
        "$_usrhome_kshrc_config" >&2
    unset _usrhome_kshrc_config
    return 1
fi

unset USRHOME_TRACE_LEVEL
# shellcheck disable=SC1090
if ! . "$_usrhome_kshrc_config"; then
    printf 'USRHOME: failed to load configuration: %s\n' \
        "$_usrhome_kshrc_config" >&2
    unset _usrhome_kshrc_config
    return 1
fi
unset _usrhome_kshrc_config

# shellcheck disable=SC2016,SC2088 # Expansion is not done and it's OK for tracing.
usrhome_trace_in '~/.kshrc --> $USRHOME_DIR/dot/kshrc.ksh'

# Do not inherit the parent shell's login flag. The shared PATH script
# uses this flag and USRHOME_CONFIG_AT_LOGIN to decide whether to update PATH.
unset USRHOME__IN_LOGIN
if [[ -o login_shell ]]; then
    USRHOME__IN_LOGIN=1
fi

# Shared aliases also load printing utilities and the PATH sanitizer.
# shellcheck source=../ibin/setfor-alias
if ! . "$USRHOME_DIR/ibin/setfor-alias"; then
    printf '%s\n' 'USRHOME: failed to load shared aliases.' >&2
    usrhome_trace_out
    return 1
fi

if [ -z "${USRHOME__IN_LOGIN-}" ] ||
   [ "${USRHOME_CONFIG_AT_LOGIN-}" = 1 ]; then
    # shellcheck source=../ibin/setfor-path
    if ! . "$USRHOME_DIR/ibin/setfor-path"; then
        printf '%s\n' 'USRHOME: failed to configure PATH.' >&2
        usrhome_trace_out
        return 1
    fi

    if command -v _usrhome_sanitize_path >/dev/null 2>&1; then
        _usrhome_sanitize_path || :
    else
        printf '%s\n' 'USRHOME: PATH sanitizer is unavailable.' >&2
    fi
fi

# A ksh-specific hook may source do-user.sh, as the Bash and Zsh hooks do.
# Until that hook exists, use do-user.sh directly when it is available.
if [ -r "$USRHOME_DIR_USRCFG/do-user-kshrc.ksh" ]; then
    # shellcheck disable=SC1091 # don't attempt to follow inside user config
    . "$USRHOME_DIR_USRCFG/do-user-kshrc.ksh"
elif [ -r "$USRHOME_DIR_USRCFG/do-user.sh" ]; then
    # shellcheck disable=SC1091 # don't attempt to follow inside user config
    . "$USRHOME_DIR_USRCFG/do-user.sh"
fi

# Load the proposed prompt selector after the user's initial PS1 setup.
if [ -r "$USRHOME_DIR/ibin/setfor-ksh-prompt" ]; then
    # shellcheck disable=SC1091
    if ! . "$USRHOME_DIR/ibin/setfor-ksh-prompt"; then
        printf '%s\n' 'USRHOME: failed to initialize the ksh prompt.' >&2
        usrhome_trace_out
        return 1
    fi
fi
# ----------------------------------------------------------------------------
# Topic: Title
# ------------
# Define set_title() and ssh4__remote()
# shellcheck source=../ibin/setfor-ksh-common
. "$USRHOME_DIR/ibin/setfor-ksh-common"

# Activate dynamic tracking title as soon as Bash takes over.
# Use a empty default Title Text.
# Inside a GNU screen we'll see the GNU screen session title if there's one.
set_title ""


usrhome_trace_out

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: ksh
# End:
