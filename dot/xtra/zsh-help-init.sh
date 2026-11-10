# Sourced script: zsh-help-init.sh  -*- mode: sh; -*-
#
# Purpose   : Help replacement for zsh.
# Created   : Tuesday, November 10 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-10 15:46:32 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sourced by the help function in dot/zshrc.zsh.
# Initialize Zsh help when it is first requested.

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

usrhome_help_init() {
    emulate -L zsh

    local chosen='' root file
    local -a roots

    # An explicit USRHOME setting takes precedence over HELPDIR.
    if [[ -n ${USRHOME_DIR_HELPDIR:-} ]]; then
        chosen=$USRHOME_DIR_HELPDIR
    elif [[ -n ${HELPDIR:-} ]]; then
        chosen=$HELPDIR
    fi

    if [[ -n $chosen ]]; then
        # Require at least one recognizable builtin help file.
        if [[ ! -d $chosen ]] ||
           [[ ! -r $chosen/cd && ! -r $chosen/print ]]; then
            print -u2 -r -- \
                "help: invalid or incomplete help directory: $chosen"
            print -u2 -r -- \
                'Set USRHOME_DIR_HELPDIR or HELPDIR to a Zsh help directory.'
            return 1
        fi
    else
        # Check common locations before starting a filesystem search.
        for root in \
            "/usr/share/zsh/$ZSH_VERSION/help" \
            /usr/share/zsh/help \
            "/usr/local/share/zsh/$ZSH_VERSION/help" \
            /usr/local/share/zsh/help \
            "/opt/homebrew/share/zsh/$ZSH_VERSION/help" \
            /opt/homebrew/share/zsh/help
        do
            if [[ -d $root ]] &&
               [[ -r $root/cd || -r $root/print ]]; then
                chosen=$root
                break
            fi
        done

        # Search only within these Zsh installation directories.
        if [[ -z $chosen ]]; then
            roots=(
                /usr/share/zsh
                /usr/local/share/zsh
                /opt/homebrew/share/zsh
            )

            for root in "${roots[@]}"; do
                [[ -d $root ]] || continue

                if (( $+commands[fd] )); then
                    while IFS= read -r -d '' file; do
                        if [[ ${file:h:t} == help && -r $file ]]; then
                            chosen=${file:h}
                            break
                        fi
                    done < <(
                        command fd -H -I -L -s -t f -0 -- \
                            '^(cd|print)$' "$root" 2>/dev/null
                    )
                elif (( $+commands[find] )); then
                    while IFS= read -r -d '' file; do
                        if [[ ${file:h:t} == help && -r $file ]]; then
                            chosen=${file:h}
                            break
                        fi
                    done < <(
                        command find -L "$root" -type f \
                            \( -name cd -o -name print \) -print0 2>/dev/null
                    )
                fi

                [[ -n $chosen ]] && break
            done
        fi
    fi

    if [[ -n $chosen ]]; then
        typeset -gx HELPDIR="$chosen"
    else
        print -u2 -r -- \
            'help: no Zsh help directory found; run-help will use its default and other help sources.'
        print -u2 -r -- \
            'If needed, set USRHOME_DIR_HELPDIR and start a new shell.'
    fi

    # Preserve an existing function, including an autoload declaration.
    # Otherwise, load the official function without executing it.
    if (( ! $+functions[run-help] )); then
        if ! autoload -Uz +X run-help; then
            unfunction run-help 2>/dev/null
            print -u2 -r -- \
                'help: run-help is not available in fpath; using man.'
            if (( $# )); then
                command man "$@"
            else
                command man zshbuiltins
            fi
            return $?
        fi
    fi

    unalias run-help 2>/dev/null

    # Skip discovery on subsequent calls in this shell.
    help() {
        \run-help "$@"
    }

    \run-help "$@"
}
# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: zsh
#  End:
