# Bash Configuration FILE: bash_logout.bash
#
# Purpose   : Bash ~/.bash_logout Configuration File - Sourced in interactive logout shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-06-27 12:29:22 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Optional Bash Logout, used by creating a ~/.bash_logout symlink to this file.
#
# The content of this file should support several Linux distributions.
# It also supports macOS.
#
# If this content does NOT corresponds to what you need, leave the ~/.bash_logout
# untouched or create a symnlink to you files stored inside the usrcfg directory.

# ----------------------------------------------------------------------------
# Code
# ----
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
#
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
if [[ -z $USRHOME_DIR ]]; then
    # - Identify the name of what bash executed (that should be the ~/.bashrc symlink)
    script=${BASH_SOURCE[0]}
    # - Then identify the real file pointed by that symlink: it should be
    #   this file,the usrhome/dot/bashrc.bash, with the complete path.
    original_script="$(readlink "$script")"
    # Then identify the parent directory of the file, that's the parent
    # of the usrcfg directory too.
    usrhome_parent="$(dirname "$(dirname "$(dirname "$original_script")")")"
    export USRHOME_DIR="$usrhome_parent/usrhome"
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"
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
usrhome_trace_in "\~/.bash_logout   --> \$USRHOME_DIR/dot/bash_logout.bash"

# ----------------------------------------------------------------------------

case $(uname) in
    'Darwin' )
    # When leaving Bash, clear Bash related icon. Rest title.
        set-title ""
        ;;

    'Linux' )
        # when leaving the console clear the screen to increase privacy
        if [ "$SHLVL" = 1 ]; then
            [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
        fi
        ;;
esac

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: bash
# End:
