#!/bin/sh
# SH FILE: test-bin-find-dir.sh
#
# Purpose   : Test USRHOME bin utilities.
# Created   : Thursday, November 26 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-26 09:03:37 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Test USRHOME find-dir utility.


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#


# ----------------------------------------------------------------------------
# Code
# ----
#
#
# • -e (errexit). Exits the script immediately if any command returns a non-zero exit status.
# • -u (nounset). Treats referencing an unset (undefined) variable as an error, printing a
#                 message to stderr and immediately exiting the script.
set -eu


# Run from the repository root.
USRHOME_DIR=$(pwd -P)
USRHOME_PRINT_ENABLED=1
USRHOME_STDERR_PRINT_TO_PIPE=1
TERM=xterm
LC_ALL=C
export USRHOME_DIR USRHOME_PRINT_ENABLED USRHOME_STDERR_PRINT_TO_PIPE TERM LC_ALL

command -v realpath >/dev/null || {
    printf '%s\n' 'ERROR: realpath is required' >&2
    exit 1
}

work=$(mktemp -d "${TMPDIR:-/tmp}/usrhome-bin-test.XXXXXX")
trap 'rm -rf "$work"' 0
work=$(CDPATH='' cd -P "$work" && pwd -P)
cd "$work"

mkdir -p 'tree/visible/target dir' 'tree/.hidden/target dir' files
: > 'files/file name'

# Exclude hidden directories by default.
"$USRHOME_DIR/bin/find-dir" 'target dir' tree > actual
printf '%s\n' 'tree/visible/target dir' > expected
cmp expected actual

# Include hidden directories when requested.
"$USRHOME_DIR/bin/find-dir" -H 'target dir' tree > actual
sort actual > sorted
printf '%s\n' 'tree/.hidden/target dir' 'tree/visible/target dir' > expected
cmp expected sorted

# An invalid root must return a status of 2 and report an error.
if "$USRHOME_DIR/bin/find-dir" 'target dir' missing > actual 2> error; then
    printf '%s\n' 'FAIL: find-dir accepted a missing root' >&2
    exit 1
else
    _test_status=$?
fi
[ "$_test_status" -eq 2 ]
grep -F 'Specified ROOT does not exists' error >/dev/null

# Normalize existing paths and omit missing paths.
printf '%s\n' "$work/files/../files/file name" \
    "$work/files/missing" "$work/files" > paths
"$USRHOME_DIR/bin/print-if-exists" < paths > actual
printf '%s\n' "$work/files/file name" "$work/files" > expected
cmp expected actual

printf '%s\n' 'PASS: bin utility tests'

# ----------------------------------------------------------------------------
