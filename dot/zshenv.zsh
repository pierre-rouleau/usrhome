# ZSH Configuration FILE: zshenv.zsh
#
# Purpose   : ~/.zshenv Z Shell Environment Configuration - Always sourced.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2024-08-02 12:44:18 EDT, updated by Pierre Rouleau>
#
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Entry point for USRHOME control of the Z Shell.
#
# To use it, create a ~/.zshenv symbolic link to this file.
#
# This file is sourced in ALL Z Shell interactions (login or non-login shell,
# interactive and non-interactive shell).
# Therefore it does the minimal required by USRHOME and nothing else:
#
# - If not already done, sets the important USRHOME environment variables:
#   - USRHOME_DIR
#   - USRHOME_DIR_USRCFG
#
# - Determines if shell tracing is activated by sourcing user's controlled
#   file: usrcfg/setfor-all-config.sh
#
#   - When tracing is required, that file must also define the USRHOME shell
#     tracing functions by sourcing file: usrhome/ibin/shell-tracing.sh
#
# - If required print tracing of this file.
#
# Nothing else is done here.  The user's configuration is NOT sourced
# here; that's done later by zshrc.

# ----------------------------------------------------------------------------
# Code
# ----
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
    # - Identify the name of what zsh executed (that should be the ~/.zshenv symlink)
    script=${(%):-%x}
    # - Then identify the real file pointed by that symlink: it should be
    #   this file, the usrhome/dot/bashrc.bash, with the complete path.
    original_script=`readlink $script`
    # - Then identify the parent directory of the file, that's the parent
    #   of the usrcfg directory too.
    usrhome_parent=$(dirname $(dirname $(dirname $original_script)))
    export USRHOME_DIR="$usrhome_parent/usrhome"
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"
fi


# 2 - Determine User Shell Configuration
# --------------------------------------
#
usrhome_config="$USRHOME_DIR_USRCFG/setfor-all-config.sh"
if [ -e $usrhome_config ]; then
    . "$usrhome_config"
else
    printf "***USRHOME ERROR!!*********************************************\n"
    printf "Cannot find the user's configuration file!\n"
    printf " Expected file: %s\n" "$usrhome_config"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/setfor-all-config.sh"
    printf "***************************************************************\n"
fi
unset usrhome_config

# 3 - Trace Shell Configuration if required
# -----------------------------------------
#
# This script needs to source user configuration scripts to
# figure out whether tracing is allowed, it sourced other files
# that reported nested tracing.  The level must be reset to 1.
if [ -n $USRHOME_TRACE_LEVEL ]; then
    unset USRHOME_TRACE_LEVEL
fi
usrhome_trace_in "~/.zshenv   --> \$USRHOME_DIR/dot/zshenv.zsh"

# ----------------------------------------------------------------------------
# Cleanup
# -------
unset usrhome_parent
unset original_script
unset script

usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
