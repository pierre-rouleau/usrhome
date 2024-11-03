# AWK FILE: au-log-syscall2name.awk
#
# Purpose   : Replace syscall function numbers by names in the audit log SYSCALL records.
# Created   : Sunday, November  3 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-03 17:08:45 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# Filter AWK script that replaces the syscall numbers by the corresponding
# function name.


# ------------------------------------------------------------------------------
# Dependencies
# ------------
#
# - GNU awk.

# ------------------------------------------------------------------------------
# Code
# ----
#
#
# Include the following file that defines the syscall array in a BEGIN clause.
# This file must have been setup prior to invocation of this awk script.
@include "/tmp/ausyscall-lookup.awk"

# Process clauses: 1 clause for the SYSCALL lines, one for the OTHERS

$4 ~ /syscall=[0-9]+/ {

    printf "%s %s %s syscall=%-15s", $1, $2, $3, syscall[gensub("^syscall=", "", 1, $4)];

    restofline=gensub("^type=[A-Z_]+ msg=audit\\([0-9]+.[0-9]+:[0-9]+\\): arch=[a-z0-9]+ syscall=[0-9]+", "", 1, $0 );
    print restofline

    line_is_processed += 1
}

$4 !~ /syscall=[0-9]+/ {
    print $0
}

# ------------------------------------------------------------------------------
