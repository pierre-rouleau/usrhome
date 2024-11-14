# ZSH Configuration FILE: zshrc
#
# Purpose   : Z Shell Recource Configuration - Define alias, functions, prompt.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-11-13 10:19:31 EST, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# To use it, create a ~/.zshrc symbolic link to this file.

# User's Z Shell RC : ~/.zshrc
# Executed at: login, new interactive shell
# Note: This is sourced: - when a terminal starts a new Z Shell
#                        - when a zsh sub-shell is started (manually or
#                          from an application)
#
# ----------------------------------------------------------------------------
# USRHOME-specific code
# ---------------------

# Topic: Emacs Tramp support
# --------------------------
#
# To allow Emacs to access this host remotely, simplify the shell startup
# to the extreme.  Tramp sets TERM to dumb (but Emacs shell also).
# - When TERM is dumb and the process is not already running under Emacs
#   set the prompt to a short string and skip all shell configuration.
#
if [ "$TERM" = "dumb" ] && [ -z "$INSIDE_EMACS" ] ; then
    PS1='$ '
    export PS1
    PROMPT='$ '
    export PROMPT
    return
fi


# Check Environment Consistency and Support Tracing
# -------------------------------------------------
#
if [[ -z "$USRHOME_DIR" ]]; then
    echo "USRHOME ERROR: environment variables not available!"
    echo "               Check your usrcfg  files!"
fi

usrhome_trace_in "~/.zshrc    --> \$USRHOME_DIR/dot/zshrc.zsh"

# ----------------------------------------------------------------------------
# Set shortcut alias for Z shell
# ------------------------------
. $USRHOME_DIR/ibin/setfor-zsh-alias

# ----------------------------------------------------------------------------
# Update Path in sub-shells if not already done
# ---------------------------------------------
. "$USRHOME_DIR/ibin/setfor-path"

# ----------------------------------------------------------------------------
# Sanitize PATH
# -------------
#
. $USRHOME_DIR/ibin/do-sanitize-path.zsh

# ----------------------------------------------------------------------------
# Activate the help for zsh builtins
# ----------------------------------
#
# The Z Shell has zsh builtin help inside a directory like the following:
#
# - Linux:  /usr/share/zsh/help
# - macOS:  /usr/share/zsh/VVV/help  , where VVV is zsh version number
#
# With zsh installed with Homebrew it might be /usr/local/share/help
#
# Unfortunately, by default, help does not work in zsh the way it does
# inside Bash. The Z Shell provides run-help but it is normally aliased
# to man and then you need to know which section of what man page to
# find the information about the Z shell builtin.
#
# The following activates a working help command for builtin inside the Z
# shell that works like the help in bash.
#
# 1 - HELPDIR:
#
# The following logic sets the HELPDIR environment variable to the
# path where the zsh files are stored, unless USRHOME_DIR_HELPDIR
# is set, in that case it uses that.
if [[ -n "$USRHOME_DIR_HELPDIR" ]]; then
    export HELPDIR="$USRHOME_DIR_HELPDIR"
else
    os_type=$(uname)
    case $os_type in
        'Darwin' )
            # The following works since at least OS/X Snow Leopard 10.6.8
            zsh_version=$(zsh --version | awk '{print $2}')
            export HELPDIR=/usr/share/zsh/${zsh_version}/help
            ;;

        *)
            # This works on Kali Linux, Ubuntu,
            # On Rocky Linux zsh may not be available, and if it is,
            # the help files may not be present in this directory
            if [[ -d /usr/share/zsh/help ]]; then
                export HELPDIR=/usr/share/zsh/help
            else
                usrhome_printf "\
WARNING! The zsh help files expected in /usr/share/zsh/help
         are not present!
         It might be a problem with the Linux distribution of zsh.
         You can get the files from the zsh source tarball in the
         Doc/help directory at:
           https://sourceforge.net/projects/zsh/files/zsh/
"
            fi
            ;;
    esac
    unset os_type
fi
if [[ -n "$HELPDIR" ]]; then
#
# Check the validity of HELPDIR and proceed if it's OK.
    if [[ -d "$HELPDIR" ]]; then
        # 2 - If necessary, Un-alias run-help, then autoload run-help
        if type run-help | grep alias > /dev/null; then
            unalias run-help 2> /dev/null
            autoload run-help
        fi
        #
        # 3 - Set an help alias
        alias help=run-help
    else
        usrhome_printf "\
WARNING! The value of HELPDIR variable is invalid!
         It should identify the location of zsh help directory,
         but the directory it identifies does not exist!
         Please investigate -- report the problem to USRHOME
                               by filing a bug report."
    fi
fi


#
# ------------------------------------------
# Update prompt
# -------------

# Topic: Prompt
# -------------

# To measure and display execution time of commands in milliseconds
# and print it inside the RPROMPT in hours, minutes, seconds, milliseconds
# with only what is relevant.  The very first time, nothing is printed.


preexec()
{
    timer=$(($(print -P %D{%s%6.})/1000))
}

precmd()
{
    if [ $timer ]; then
        # get time with millisecond resolution
        now=$(($(print -P %D{%s%6.})/1000))

        # compute time elements
        local e_ms=$(($now-$timer))
        local e_s=$((e_ms / 1000))
        local ms=$((e_ms % 1000))
        local s=$((e_s % 60))
        local m=$(((e_s / 60) % 60))
        local h=$((e_s / 3600))

        # Format elapsed according to the elapsed time elements
        if   ((h > 0)); then elapsed=${h}h${m}m${s}s                      # example: 1h2m3s
        elif ((m > 0)); then elapsed=${m}m${s}.$(printf $(($ms / 100)))s  # example: 1m12.3s
        elif ((s > 9)); then elapsed=${s}.$(printf %02d $(($ms / 10)))s   # example: 12.34s
        elif ((s > 0)); then elapsed=${s}.$(printf %03d $ms)s             # example: 1.234s
        else elapsed=${ms}ms
        fi
        unset timer
    fi
}



# - Use PROMPT instead of PS1
# - Use RPROMPT to get a git status on the right side.

# It would be possible to display a prompt on 2 lines with the following:
#     precmd() { print -rP "%B%? [%D{%H:%M:%S}] L:%L %n@%m:%~ %#%b " }
#     export PROMPT=""
#
# A new line can also be placed in the prompt with: $'\n'
# Both work but does not render properly inside Emacs pel-shell.
# It also prints the right side info on the second line.

# A better way is to display the path in the left side, but limited to the
# last 2 directory names in the path.  And then print the complete path inside
# the right side of the prompt, in bold, followed by a VCS status for Git.
# This way, on the left side prompt, I can print:
#
# - The value of last command exit code: %?
# - Time in 24-hour [hh:mm:ss] format:   [%D{%H:%M:%S}]
# - Shell nesting level:                 %L
# - User name                            %n
# - Host name                            %m
# - last 2 components of pwd             %2~
# - % for normal prompt, # for sudo      %#
# - all of the above in bold: %B ... %b

# Dynamically change prompt.
# Support "$USRHOME_DIR/ibin/setfor-prompt-model-to":
#  Use  $USRHOME_PROMPT_MODEL_OVERRIDE if it exists,
#   otherwise use $USRHOME_PROMPT_MODEL.

usrhome-select-zsh-prompt()
{
    # To support Emacs Tramp (which sets TERM to "dumb", use a very simple prompt
    # to avoid confusing Tramp's prompt parsing.
    # However, when the shell is running inside Emacs don't do it as it may be
    # the shell-mode buffer.
    if [ "$TERM" = "dumb" ] && [ -z "$INSIDE_EMACS" ] ; then
        PS1='$ '
        export PS1
        PROMPT='$ '
        export PROMPT
    else

        p1=$'>%?@%B%D{%H:%M:%S} L%L'

        if [ "$USRHOME_PROMPT_SHOW_USR_HOST" = "1" ]; then
            p2=$'%n@%m:[%~%b]'
        else
            p2=$'[%~%b]'
        fi

        if [ -n "$USRHOME_PROMPT_MODEL_OVERRIDE" ]; then
            model="$USRHOME_PROMPT_MODEL_OVERRIDE"
        else
            model="$USRHOME_PROMPT_MODEL"
        fi
        case "$model" in
            0 )
                # This is a special case.
                #
                # - If the user file "$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"
                #   defines a complex prompt that must be re-loaded with a
                #   shell restart, the it must identify it by defining the
                #   USRHOME_PROMPT_MODEL_REQUIRES_RESTART and set its value
                #   to the shell model value; which is 0 in this case.
                #   When this is the case no prompt definition logic is
                #   provided here, but the setfor-prompt-model-to checks the
                #   USRHOME_PROMPT_MODEL_REQUIRES_RESTART value and restart
                #   the shell.
                # - If the user configuration file does not set the
                #   USRHOME_PROMPT_MODEL_REQUIRES_RESTART envvar, then
                #   this code sets a simple prompt for zsh.
                if [ -z "$USRHOME_PROMPT_MODEL_REQUIRES_RESTART" ] || [ ! "$USRHOME_PROMPT_MODEL_REQUIRES_RESTART" = "0" ]; then
                    export PROMPT='%n@%m %1~ :zsh%# '
                fi
                ;;

            2 | 3 )
                # Select tail end of prompt.
                # Model 2: print zsh followed by % or #, in bold and in color:
                #          - user mode: green when last command succeeded,  bold red otherwise.
                #          - root     : magenta when last command succeeded, bold red otherwise.
                # Model 3: print zsh followed by % or # in bold
                case "$model" in
                    2)
                        p3=%(?.%F{%(#.magenta.green)}zsh%#%F{reset}.%B%F{red}zsh%#%F{reset}%b)
                        ;;
                    3)
                        p3=%Bzsh%#%b
                        ;;
                esac
                autoload -Uz vcs_info
                precmd_vcs_info() { vcs_info }
                precmd_functions+=( precmd_vcs_info )
                setopt prompt_subst
                zstyle ':vcs_info:hg:*'  formats '%F{240}hg:(%b)%r%f'
                zstyle ':vcs_info:git:*' formats '%F{240}git:(%b)%r%f'
                zstyle ':vcs_info:*' enable hg git
                export PROMPT=$'$p1 $p2 \ \$vcs_info_msg_0_\n$p3 '

                # Show the exit code and the current sub-process jobs inside the RPROMPT
                # but only when the shell is not used inside Emacs or used inside an Emacs vterm shell.
                if [[ -z "$INSIDE_EMACS" ]] || [[ -n "$EMACS_VTERM_PATH" ]] ; then
                    #          exit code: value x on failure  #jobs when more than 1
                    RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}. %F{cyan}${elapsed} %{$reset_color%})'
                fi
                ;;

            * )
                # Default (also model 1)
                export PROMPT=$'$p1 $p2 '

                # Note that the prompt starts with a '>', the exit code and a '@'.  It is
                # therefore possible to create a regexp that identifies a prompt line.
                #
                # That is useful inside Emacs (in pel-shell-prompt-line-regexp) and inside
                # scripts that can identify consecutive prompts from a log and then compute
                # the elapsed time for a given command.
                if [ -z $INSIDE_EMACS ]; then
                    # Unless inside Emacs, display full path at right
                    # followed by Git information if inside a Git repo directory.
                    # This is shown only if there is space in the window.
                    # The info can be shown in term-mode but not in shell-mode (I don't know why).
                    # Inside Emacs it's not that useful anyway because Emacs can display that information.
                    autoload -Uz vcs_info
                    precmd_vcs_info() { vcs_info }
                    precmd_functions+=( precmd_vcs_info )
                    setopt prompt_subst
                    RPROMPT=%B%~%b\ \$vcs_info_msg_0_
                    zstyle ':vcs_info:hg:*'  formats 'hg:%F{240}(%b)%r%f'
                    zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
                    zstyle ':vcs_info:*' enable hg git
                fi
                ;;
        esac
    fi
}

# Activate selected prompt
usrhome-select-zsh-prompt

# ----------------------------------------------------------------------------
# Topic: emacs-eat integration
# ----------------------------

if [ "${INSIDE_EMACS/*,/}" = "eat" ] && [ -n "$EAT_SHELL_INTEGRATION_DIR" ]; then
    if [ -d "$EAT_SHELL_INTEGRATION_DIR" ]; then
        echo ".  Activating emacs-eat integration."
        . "$EAT_SHELL_INTEGRATION_DIR/zsh"
    fi
fi

# Topic: Title
# ------------
# Define set_title() and ssh4__remote()
. "$USRHOME_DIR/ibin/setfor-zsh-common"

# ----------------------------------------------------------------------------
# Source User Extra zshrc if it exists
# ------------------------------------
#
# This is done last.  Allowing user's code to overwrite variables and
# functions defined by USRHOME logic.
#
user_zshrc="$USRHOME_DIR_USRCFG/do-user-zshrc.zsh"
if [ -e "$user_zshrc" ]; then
    . "$user_zshrc"
else
    usrhome_printf "***USRHOME ERROR!!*********************************************\n"
    usrhome_printf "Cannot find the user's Z shell configuration file!\n"
    usrhome_printf " Expected file: %s\n" "$user_zshrc"
    usrhome_printf " Please write it, use the template example as basis.\n"
    usrhome_printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/do-user-zshrc.zsh"
    usrhome_printf "***************************************************************\n"
fi
unset user_zshrc
# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
