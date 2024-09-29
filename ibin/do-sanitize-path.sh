# Sourced script: do-sanitize-path  -*- mode: sh; -*-
#
# Purpose   : Sanitize current shell PATH.
# Created   : Saturday, April  6 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-09-29 08:55:04 EDT, updated by Pierre Rouleau>
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
#  - POSIX shell utilities: printf, tr, sed, awk, wc, xargs, tail
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

path_entries="$(printf "%s\n" "$PATH" | tr ':' '\n' | wc -l | xargs)"
sanitized_path="$(printf "%s" "$PATH" | sed 's/::/:/g' | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':')"

# remove any trailing ':' character
if [ "$(printf "%s" "${sanitized_path}"  | tail -c 1)"  = ":" ]; then
    sanitized_path="$(printf "%s" "$sanitized_path" | sed 's/.$//')"
fi

sanitized_path_entries="$(printf "%s\n" "$sanitized_path" | tr ':' '\n' | wc -l | xargs)"
if [ "$path_entries" != "$sanitized_path_entries" ]; then
    if [ "$SHELL_IS_INTERACTIVE" = "true" ] && [ ! "$TERM" = "dumb" ]; then
        echo "WARNING: USRHOME has sanitized your PATH!"
        echo "Original PATH: $PATH"
        if [ "$USRHOME_TRACE_SHELL_CONFIG" = "1" ]; then
            printf "%s\n" "         It had $path_entries directories, it now has $sanitized_path_entries."
            echo " The original PATH was:"
            showpath -n
        else
            echo "Set USRHOME_TRACE_SHELL_CONFIG to 1 in to see more info."
            echo "- Edit: \$USRHOME_DIR_USRCFG/setfor-all-config.sh"
        fi
    fi
fi
export PATH="$sanitized_path"

# cleanup
unset path_entries
unset sanitized_path
unset sanitized_path_entries

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
