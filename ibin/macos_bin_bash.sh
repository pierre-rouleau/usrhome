#!/bin/sh
# SH FILE: macos_bin_bash.sh
#
# Purpose   : Simulate a login bin/bash (the old GNU bash).
# Created   : Thursday, May 30 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-30 16:33:17 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# For macOS only.  Simulate a login Bash shell that uses the old Bash
#                  still installed in the macOS systems.
#
# To use: set Terminal.app Preferences/Profiles/Shell/Run command
#         to this file using the absolute path.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
USRHOME__IN_LOGIN=1
export USRHOME__IN_LOGIN
/bin/bash --login

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: sh
# End:
