# Bash Configuration FILE: bash_login.bash
#
# Purpose   : Bash ~/.bash_login Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-09-29 17:17:00 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
# This file, normally identified by the ~/.bash_login symbolic link,
# is the POSIX profile configuration entry point.
#
# The current implementation is empty; USRHOME does not yet support
# adding user specific logic to it.  All it does is participate in the
# USRHOME configuration tracing.
#
# If you need something done by ~/.bash_login on your system, write your own
# ~/.bash_login and do not symlink to here.

# ----------------------------------------------------------------------------
# USRHOME-Specific Code
# ---------------------
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
    usrhome_printf "\
***USRHOME ERROR!!*********************************************
Cannot find the user's configuration file!
 Expected file: %s
 Please write it, use the template example as basis.
 The template is: %s
 ***************************************************************
" "$usrhome_config" "$USRHOME_DIR/template/usrcfg/setfor-all-config.sh"
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
usrhome_trace_in "~/.bash_login   --> \$USRHOME_DIR/dot/bash_login.bash"

# ----------------------------------------------------------------------------
# User-Specific Logic
# -------------------


# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: bash
# End:
