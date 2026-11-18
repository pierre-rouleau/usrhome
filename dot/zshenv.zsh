# ZSH Configuration FILE: zshenv.zsh
# shellcheck shell=sh
#
# Purpose   : ~/.zshenv Z Shell Environment Configuration - Always sourced.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Copyright (C) 2024-2026 by Pierre Rouleau
# Created   : Monday, March 18 2024.
# Time-stamp: <2026-11-18 11:48:19 EST, updated by Pierre Rouleau>
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
# This file is $USRHOME_DIR/dot/zshenv.zsh
#
# The USRHOME system creates symlink in ~/zshenv to this file.
# The code extracts the value of the USRHOME_DIR environment variable
# from the value of the symlink and the knowledge of where the file resides
# as described above.
#
# The next step: identify the value of the USRHOME_DIR_USRCFG environment
# variable: use the convention that the value of USRHOME_DIR and the value
# of USRHOME_DIR_USRCFG are siblings: the first identifies the usrhome
# directory while the second identifies the usrcfg directory.
# USRHOME imposes that convention.
#
# If it has already been done, as indicated by the existence of the
# USRHOME_DIR environment variable, then skip this part.
#
if [ -z "${USRHOME_DIR-}" ]; then
    # - Identify the name of what zsh executed (that should be the ~/.zshenv symlink)
    # shellcheck disable=SC2296 # shellcheck does not support zsh syntax
    script=${(%):-%x}
    # Read the symlink target. It should identify usrhome/dot/zshenv.zsh.
    if ! original_script=$(readlink "$script"); then
        printf 'USRHOME: cannot read the zshenv link: %s\n' "$script" >&2
        return 1
    fi

    # Anchor a relative target to the directory containing the symlink.
    case $original_script in
        # absolute symlink target; keep unchanged.
        /*)
        ;;

        # relative symlink target: use an absolute path in envvar
        *)
            case $script in
                */*) script_dir=${script%/*}
                     [ -n "$script_dir" ] || script_dir=/ ;;
                *)   script_dir=. ;;
            esac
            if ! script_dir=$(CDPATH='' cd -P -- "$script_dir" && pwd -P); then
                printf 'USRHOME: cannot resolve the zshenv link directory: %s\n' "$script" >&2
                return 1
            fi
            original_script=$script_dir/$original_script
            ;;
    esac

    # - Then identify the parent directory of the file, that's the parent
    #   of the usrcfg directory too.
    usrhome_parent=${original_script%/}   # Remove any trailing slash first
    usrhome_parent=${usrhome_parent%/*}   # 1st dirname
    usrhome_parent=${usrhome_parent%/*}   # 2nd dirname
    usrhome_parent=${usrhome_parent%/*}   # 3rd dirname
    export USRHOME_DIR="$usrhome_parent/usrhome"
    export USRHOME_DIR_USRCFG="$usrhome_parent/usrcfg"
fi


# 2 - Determine User Shell Configuration
# --------------------------------------
#
usrhome_config="$USRHOME_DIR_USRCFG/setfor-all-config.sh"
if [ -e "$usrhome_config" ]; then
    # shellcheck source=../../usrcfg/setfor-all-config.sh
    . "$usrhome_config"
else
    printf -- "\
***USRHOME WARNING!!*********************************************
Cannot find the user's configuration file!
 Expected file: %s
 Please write it, use the template example as basis.
 The template is: %s

 Proceeding without user-specific configuration.
  USRHOME specific commands and prompts are available
  with default settings.

 For more information, see
 https://github.com/pierre-rouleau/usrhome/blob/main/readme.rst#the-z-and-bash-shell-startup-dot-files-and-user-configuration

***************************************************************
" "$usrhome_config" "$USRHOME_DIR/template/usrcfg/setfor-all-config.sh"

    # When usrcfg is not defined, disable any tracing by defining dummy functions.
    usrhome_trace_in()
    {
        printf -- ""
    }

    usrhome_trace_out()
    {
        printf -- ""
    }

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

#shellcheck disable=SC2088 # The tilde does not need to be expanded
usrhome_trace_in "~/.zshenv   --> \$USRHOME_DIR/dot/zshenv.zsh"

# ----------------------------------------------------------------------------
# Cleanup
# -------
unset usrhome_parent
unset original_script
unset script_dir
unset script

usrhome_trace_out
# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
