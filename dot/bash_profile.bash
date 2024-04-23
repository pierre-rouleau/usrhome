# Bash Configuration FILE: bash_profilen.bash
#
# Purpose   : Bash ~/.bash_profile Configuration File - Sourced in interactive login shell.
# Created   : Sunday, April  7 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-23 15:10:17 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
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
# The file sets the usrhome_inside_bash_profile variable and then sources the
# $USRHOME_DIR/dot/bashrc.bash file as would most implementation would do.
# Then it unset the variable.  This way the other sourced files can detect if
# they are sourced during login.
#
# However, before doing it, it executes the logic that allows activation of
# the USRHOME tracing.

# ----------------------------------------------------------------------------
# Code
# ----
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


# 2 - Determine is shell tracing is activated
# -------------------------------------------
#
usrhome_trace_activation="$USRHOME_DIR_USRCFG/setfor-shell-tracing.sh"
if [ -e "$usrhome_trace_activation" ]; then
    . "$usrhome_trace_activation"
else
    printf "***USRHOME ERROR!!*********************************************\n"
    printf "Cannot find the user's shell tracing configuration file!\n"
    printf " Expected file: %s\n" "$usrhome_trace_activation"
    printf " Please write it, use the template example as basis.\n"
    printf " The template is: %s\n" "$USRHOME_DIR/template/usrcfg/setfor-shell-tracing.sh"
    printf "***************************************************************\n"
fi
unset usrhome_trace_activation


# 3 - Define USRHOME shell tracing functions
# ------------------------------------------
. "${USRHOME_DIR}/ibin/shell-tracing.sh"


# 4 - Trace Shell Configuration if required
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
# - The ~/.bash_profile sources ~/.bashrc if it exists.
#   - In the case of USRHOME implementation ~/.bashrc
#     does exists: it is implemented as usrhome/dot/bashrc.bash
#
# Set usrhome_inside_bash_profile variable to true; this can be used
# within usrhome/dot/bashrc.bash to determine if it is running during
# a login or not.

# shellcheck disable=SC2034
usrhome_inside_bash_profile=true
. "$USRHOME_DIR/dot/bashrc.bash"
unset usrhome_inside_bash_profile

# ----------------------------------------------------------------------------
# Cleanup
usrhome_trace_out
# ----------------------------------------------------------------------------
