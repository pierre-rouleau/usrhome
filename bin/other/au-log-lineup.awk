# AWK FILE: au-log-lineup.awk
#
# Purpose   : Line up the Audit log: make first field always same size.
# Created   : Saturday, November  2 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-02 21:42:28 EDT, updated by Pierre Rouleau>
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
}

/^type=[A-Z_]+/ {

    # print the first file, padded.
    printf "%-21s", $1;

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
