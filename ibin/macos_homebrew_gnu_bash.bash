#!/opt/homebrew/bin/bash
# SH FILE: macos_homebrew_gnu_bash.bash
#
# Purpose   : Simulate a login bash (using a Homebrew GNU bash).
# Created   : Thursday, May 30 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-30 16:33:34 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# For macOS only.  Simulate a login Bash shell using the Homebrew provided
#                  GNU Bash, a more recent version than what is available
#                  on macOS normally.  It supports the old Intel-based
#                  computers where Homebrew installs in /usr/local/bin, and
#                  the Apple Silicon computers where Homebrew installs
#                  inside the /opt/homebrew/bin
#
# To use: set Terminal.app Preferences/Profiles/Shell/Run command
#         to this file using the absolute path.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# Homebrew bash must be installed.  Use `brew install bash` to install it.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
USRHOME__IN_LOGIN=1
export USRHOME__IN_LOGIN
case "$(arch)" in
    arm64) /opt/homebrew/bin/bash --login ;;
    i386)  /usr/local/bin/bash    --login ;;
esac

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: bash
# End:
