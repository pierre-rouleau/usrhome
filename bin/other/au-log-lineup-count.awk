# AWK FILE: au-log-lineup-count.awk
#
# Purpose   : File filter: line up the audit log and prefix it with a record count.
# Created   : Saturday, November  2 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-05 14:11:07 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# Filter program that aligns text following the first field of an audit log.
#
# It transforms the following:
#
#   type=DAEMON_START msg=audit(1728599330.944:4002): op=start ver=3.1.2 ...
#   type=CONFIG_CHANGE msg=audit(1728599330.966:280): op=set audit_backlog ...
#   type=SYSCALL msg=audit(1728599330.966:280): arch=c000003e syscall=44 ...
#
# Into:
#
#   type=DAEMON_START     msg=audit(1728599330.944:4002): op=start ver=3.1.2 ...
#   type=CONFIG_CHANGE    msg=audit(1728599330.966:280): op=set audit_backlog ...
#   type=SYSCALL          msg=audit(1728599330.966:280): arch=c000003e syscall=44 ...
#
# CAUTION: Use this script as a FILE filter.
#          It MUST process ALL lines of the file (or standard input)
#          because it maintains a state over the lines.
#          It will work to process single lines but won't be able to maintain
#          the state over the lines and will always print line number as 1.
#
#          If you want to use a line-oriented filter, use the au-log-lineup.awk
#          instead.

# ------------------------------------------------------------------------------
# Dependencies
# ------------
#
# - GNU awk  (also implemented as gawk on some systems).


# ------------------------------------------------------------------------------
# Code
# ----
#
# Every line from the stdin is printed.
# - The lines that start with "type=" are right padded to take 21 characters,
#   because the maximum length of type names is 16: (16 + len('type=') == 21).
# - All other lines are printed unchanged.

BEGIN {
    line_is_processed=0

    # By default use a width that is enough for type=SYSCALL
    # Later, keep track of that width and increase it if necessary.
    my_type_width=12

    # Count lines
    line_number=1
}

/^type=[A-Z_]+/ {

    # Update width according to what's found on the field type.
    current_type_width=length($1)
    if ( current_type_width > my_type_width) {
        my_type_width = current_type_width
    }

    # print the first file, padded.
    printf "#%3d %-*s", line_number, my_type_width, $1;
    line_number += 1;

    # Then print all other fields.
    # Instead of trying to loop through all remaining fields and printing them
    # with spaces in between, just compute the remainder and print that. This
    # way we won't inject extra spaces in various locations.
    restofline=gensub("^type=[A-Z_]+", "", 1, $0 );
    print restofline

    # Prevent next clause to print, since we've already printed the line.
    line_is_processed=1
}

line_is_processed == 0   { print }

# ------------------------------------------------------------------------------
