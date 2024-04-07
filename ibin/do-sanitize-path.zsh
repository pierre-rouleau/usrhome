# Sourced script: do-sanitize-path  -*- mode: zsh; -*-
#
# Purpose   : Sanitize current shell PATH.
# Created   : Saturday, April  6 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-04-07 12:21:09 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize the current shell's PATH
# - Replace '::' by ':'
# - Remove duplicate entries in the PATH, leave first one seen.
#
# BUGS: Does not check if specified directories are present.
#       TODO: to be done later.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#  - zsh shell utilities: printf, tr, sed, awk, wc, xargs
#  - USRHOME showpath
#

# ----------------------------------------------------------------------------
# Code
# ----
#
#
# - Replace '::' by ':'
# - Remove duplicate entries in the PATH, leave first one seen.
# - Then remove the trailing ':' injected.
#
# If the old path had to be sanitized, display a warning
# describing the number of directory entries in each.
# Use xargs to remove leading spaces from the number strings.

path_entries="$(printf "%s" "$PATH" | tr ':' '\n' | wc -l | xargs)"
sanitized_path="$(printf "%s" "$PATH" | sed 's/::/:/g' | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':')"

# remove any trailing ':' character
if [[ "${sanitized_path:0-1}" = ":" ]]; then
    sanitized_path="${sanitized_path: 0:-1}"
fi

sanitized_path_entries="$(printf "%s" "$sanitized_path" | tr ':' '\n' | wc -l | xargs)"
if [[ "$path_entries" != "$sanitized_path_entries" ]]; then
    echo "WARNING: USRHOME has sanitized your PATH!"
    if [[ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]]; then
        echo "         It had $path_entries directories, it now has $sanitized_path_entries."
        echo " The original PATH was:"
        showpath -n
    else
        echo "Set USRHOME_TRACE_SHELL_CONFIG to 1 in to see more info."
        echo "- Edit: \$USRHOME_DIR_USRCFG/setfor-zsh-config.zsh"
    fi
fi
export PATH=$sanitized_path

# cleanup
unset path_entries
unset sanitized_path
unset sanitized_path_entries

# ----------------------------------------------------------------------------
