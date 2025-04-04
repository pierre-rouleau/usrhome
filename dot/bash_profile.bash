# Bash Configuration FILE: bash_profile.bash
#
# Purpose   : Bash ~/.bash_profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-09-29 17:23:43 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Description
# -----------
#
#  This USRHOME/dot/bash_profile.bash file is meant to be identified by the
#  ~/.bash_profile symlink.  It provides:
#
#  - the USRHOME-specific code that supports tracing of the shell
#    configuration files, then it
#  - sources the user-provided usrcfg/do-user-bash_profile.bash file
#    it it exists, then it
#  - sources the usrhome/dot/bashrc.bash file to mimic what most Bash
#    implementation do.
#
#
# On macos
# --------
#
# On macOS with Bash as the default shell, the ~/.bash_profile file is executed
# when Terminal starts.  The implementation should normally source the ~/.bashrc
# file.
#
# When a Bash sub-shell is started without any option it is started as an
# interactive, non-login shell and it only source the ~/.bashrc.
#
# - Logic stored only in the ~/.bash_profile will be processed only for login
#   shells.
# - Logic stored in ~/.bashrc is only be processed in interactive shells.
#
# On Linux
# --------
#
# On the various Linux distributions I tested so far, the ~/.profile file is
# not processed.
#
#
# With USRHOME
# ------------
#
# To simplify the implementation and support various macOS versions and Linux
# distributions, USRHOME design forces putting **all** Bash control logic
# inside  ~/.bashrc.  More precisely into the usrhome/dot/bashrc.bash file
# pointed to by the ~/.bashrc symlink.
#
# The file sets the USRHOME__IN_LOGIN to 1 to indicate the sourcing of the
# configuration file by a login shell. It then sources the
# $USRHOME_DIR/dot/bashrc.bash file as would most implementation would do.
#
# However, before doing it, it executes the logic that allows activation of
# the USRHOME tracing.

# ----------------------------------------------------------------------------
# Code
# ----
#
# 0 - Check if shell is interactive
# ---------------------------------
# Note: it is used inside usrhome_printf()

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
usrhome_trace_in "~/.bash_profile   --> \$USRHOME_DIR/dot/bash_profile.bash"

# ----------------------------------------------------------------------------
# Mimic behaviour found on most Bash implementations:
#
# - Execute the usercfg/do-usr-bash_profile.bash if it exists, which
#   corresponds to executing user's logic stored in ~/.bash_profile.
#
# - The ~/.bash_profile sources ~/.bashrc if it exists.
#   - In the case of USRHOME implementation ~/.bashrc
#     does exists: it is implemented as usrhome/dot/bashrc.bash
#

# Set USRHOME__IN_LOGIN to 1 when this is a Bash login shell.
# - On Linux, when this file is executed, it's always a login bash shell.
# - On macOS, for Bash, it is always executed, even for interactive shells.
#   Therefore, to be able to distinguish between a login and a non-login
#   shell on macOS, we don't set USRHOME__IN_LOGIN to 1 here.
#   Instead configure your terminal application to use one of
#   the following bash launchers:
#
#   - usrhome/ibin/macos_bin_bash.sh
#   - usrhome/ibin/macos_homebrew_gnu_bash.bash

if [ "$(uname)" != "Darwin" ]; then
    # shellcheck disable=SC2034
    USRHOME__IN_LOGIN=1
fi

if [ -f "$USRHOME_DIR_USRCFG/do-user-bash_profile.bash" ]; then
    # shellcheck disable=SC1091
    . "$USRHOME_DIR_USRCFG/do-user-bash_profile.bash"
fi

# Inform other files the shell configuration is done during the setup of a login shell.
# shellcheck disable=SC1091
. "$USRHOME_DIR/dot/bashrc.bash"
if [ "$(uname)" != "Darwin" ]; then
    unset USRHOME__IN_LOGIN
fi

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: bash
# End:
