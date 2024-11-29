# AWK FILE: au-extra-format.awk
#
# Purpose   : Lin-oriented filter: line up audit log
# Created   : Thursday, November 21 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-22 17:30:34 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# This line-oriented filter expects an input stream that is the output of
# 'ausearch -i'.  It provides supplemental formatting:
#
# - Lines up the 3rd field (which begins with 'msg=audit(.... )'
# - Removes the arch=xxxx from the SYSCALL records

# ------------------------------------------------------------------------------
# Dependencies
# ------------
#
# - GNU awk

# ------------------------------------------------------------------------------
# Code
# ----
#
#

BEGIN {
    field_processed=0

    # By default use a width that is enough for type=SYSCALL
    my_type_width=12
    my_syscall_width=10
}


/^type=[A-Z_]+/ {

    # Get record type name to print it without the 'type=' prefix
    type_name = gensub("type=", "", 1, $1)

    # print the record type, padded but without the prefix.
    printf "%-*s ", my_type_width, type_name;

    # compute and print the rest of the line
    restofline=gensub("^type=[A-Z_]+ ", "", 1, $0);
    sub(" arch=[a-zA-Z0-9_]+ ", " ", restofline)
    print restofline

    # Remember to print all fields after the first.
    field_processed=1
}


field_processed == 0   { print }


# ------------------------------------------------------------------------------
