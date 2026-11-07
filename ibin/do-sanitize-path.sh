# Sourced script: do-sanitize-path.sh  -*- mode: sh; -*-
#
# Purpose   : Sanitize current shell PATH.
# Created   : Saturday, April  6 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-06 18:05:09 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize the current shell's PATH
# - Replace '::' by ':'
# - Remove duplicate entries in the PATH, leave first one seen.
# - Remove any trailing ':'
# - Remove leading whitespace
#
# BUGS: Does not check if specified directories are present.
#       TODO: to be done later.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#

# ----------------------------------------------------------------------------
# Code
# ----
#
#

# Legacy entry point: always sanitize PATH.
# shellcheck disable=SC1091 # fail to identify file
. "${USRHOME_DIR}/ibin/xtra/sanitize-path.bash" || return 1
_usrhome_sanitize_path PATH

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
