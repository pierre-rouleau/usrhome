# Sourced script: confirm-shell-restart.sh  -*- mode: sh; -*-
#
# Purpose   : Helper functions for commands that replace the current shell.
# Created   : Tuesday, November 10 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-12 11:30:15 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# This provide helper functions use to prompt the user about to use a command
# that will erase the shell's history.

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

# Sourced helper for commands that replace the current shell.

usrhome_confirm_shell_restart()
{
    # Retain the existing jobs check.
    if [ -n "$(jobs)" ]; then
        usrhome_print_error 'Unfinished jobs exist. Terminate them before restarting the shell.'
        return 1
    fi

    case $- in
        *i*) ;;
        *)
            usrhome_print_error 'Cannot confirm a shell restart in a non-interactive shell.'
            return 1
            ;;
    esac

    if [ ! -t 0 ] || [ ! -t 2 ]; then
        usrhome_print_error 'Cannot confirm a shell restart without terminal input and output.'
        return 1
    fi

    usrhome_print_warning 'Restarting the shell may lose unsaved shell history and other shell state.'
    printf '%s' 'Restart the shell? [y/N] ' >&2

    # process user's reply without executing exit to prevent Zsh exit hook to execute
    # and print information in the terminal.
    if (
        if IFS= read -r usrhome__answer; then
            case "$usrhome__answer" in
                y | Y) true ;;
                *) false ;;
            esac
        else
            false
        fi
    ); then
        return 0
    fi

    printf '\n%s\n' 'Shell restart cancelled.  Nothing done.' >&2
    return 1
}

usrhome_prompt_restart_preflight()
{
    #shellcheck source=../which-shell
    . "$USRHOME_DIR/ibin/which-shell" || return 1

    if [ "$USRHOME_SHELL" = zsh ] &&
       [ -n "${USRHOME_PROMPT_MODEL_REQUIRES_RESTART-}" ] &&
       [ "$1" = "$USRHOME_PROMPT_MODEL_REQUIRES_RESTART" ]; then
        usrhome_confirm_shell_restart || return 1
    fi
    return 0
}

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
