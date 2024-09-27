# Sourced script: fpath.sh  -*- mode: sh; -*-
# SH FILE: fpath.sh
#
# Purpose   : File path processing functions.
# Created   : Friday, September 27 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>, based on https://github.com/Offirmo/offirmo-shell-lib
# Time-stamp: <2024-09-27 16:12:54 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Utility functions to compute path relationships.


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# - POSIX sh


# ----------------------------------------------------------------------------
# Code
# ----
#
#

usrhome_relpath() {
    # Arguments:
    # $1 : absolute directory path 1.  The base one.
    # $2 : directory path 2.
    #
    #   Both path must be absolute and must be canonical; none
    #   of their directory component can be '.' or '..'.
    #   Symbolic links are not followed.

    # Returns:
    # - variable result: relative path from $1 to $2

    # Environment:
    #
    # USRHOME__TEST : when set, runs the test code.

    dirpath1=$1
    dirpath2=$2

    common_part=$dirpath1
    result=

    while [ "${dirpath2#"$common_part"}" = "$dirpath2" ]; do
        # no match, means that candidate common part is not correct
        # go up one level (reduce common part)
        common_part=$(dirname "$common_part")
        # and record that we went back, with correct / handling
        if [ -z "$result" ]; then
            result=..
        else
            result=../$result
        fi
    done

    if [ "$common_part" = / ]; then
        # special case for root (no common path)
        result=$result/
    fi

    # since we now have identified the common part,
    # compute the non-common part
    forward_part=${dirpath2#"$common_part"}

    # and now stick all parts together
    if [ -n "$result" ] && [ -n "$forward_part" ]; then
        result=$result$forward_part
    elif [ -n "$forward_part" ]; then
        # extra slash removal
        result=${forward_part#?}
    fi

    if [ -n "$USRHOME__TEST" ]; then
        printf -- "usrhome_relpath %-20s %-20s : %s\n" "$1" "$2" "$result"
    fi
}

# ----------------------------------------------------------------------------
# Test code
#
# Execute like this:  USRHOME__TEST=1 ./fpath.sh
#
if [ -n "$USRHOME__TEST" ]; then
    usrhome_relpath "/a/b/c" "/a"
    usrhome_relpath "/a"         "/a/b/c"
    usrhome_relpath "/user/test" "/user/test"
    usrhome_relpath "/user/test" "/user/test/ghi.txt"
    usrhome_relpath "/user/test" "/user/test/abc"
fi

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
