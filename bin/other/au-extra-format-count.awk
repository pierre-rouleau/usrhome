# AWK FILE: au-extra-format-count.awk
#
# Purpose   : File filter: line up audit log, report AVC records
# Created   : Thursday, November 21 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-22 17:52:21 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# This file-oriented filter expects an input stream that is the output of
# 'ausearch -i'.  It provides supplemental formatting:
#
# - Add a line count prefix
# - Lines up the 3rd field (which begins with 'msg=audit(.... )'
# - Removes the arch=xxxx from the SYSCALL records, but remembers it an prints
#   it in the final report.
# - Print a final report identifying the architecture and the number of AVC
#   records detected in the input stream.

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
    # Later, keep track of that width and increase it if necessary.
    my_type_width=12
    my_syscall_width=5
    found_architecture=""
    selinux_avc_count=0

    # Count lines
    line_number=1
}

# Process field 4 of SYSCALL records: Identify architecture
$6 ~ /syscall=[a-z0-9]+/ {

    # SYSCALL record identify the CPU architecture.
    # It's not printed in the record, but printed at the end (once).
    found_architecture = $5
    sub("arch=", "", found_architecture)
}


/^type=[A-Z_]+/ {

    # Update width according to what's found on the field type.
    current_type_width=length($1)
    if ( current_type_width > my_type_width) {
        my_type_width = current_type_width
    }

    # Count AVC records
    type_name = gensub("type=", "", 1, $1)
    if ( type_name == "AVC" ) {
        selinux_avc_count += 1
    }

    # print the first record portion with line number and padded type.
    printf "#%3d %-*s ", line_number, my_type_width, type_name;
    line_number += 1;

    # Remember to print all fields after the first.
    field_processed=1

    # compute the rest of the line
    restofline=gensub("^type=[A-Z_]+ ", "", 1, $0);
    sub(" arch=[a-zA-Z0-9_]+ ", " ",   restofline)
    print restofline
}

field_processed == 0   { print }

END {
    print "---- TRAILING INFORMATION ----"
    print "- CPU Architecture: " found_architecture
    if ( selinux_avc_count != 0 ) {
        print "- The above log has " selinux_avc_count " SELinux AVC records."
        print "  SELinux notes:"
        print "   - S-context := security context of process."
        print "   - T-context := security context of file."
    }
    print "------------------------- ----"
}

# ------------------------------------------------------------------------------
