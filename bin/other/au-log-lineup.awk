# AWK FILE: au-log-lineup.awk
#
# Purpose   : Line up the Audit log: make first field always same size.
# Created   : Saturday, November  2 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-11-05 17:10:36 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# Filter program that:
# - aligns text following the first field of an audit log.
# - Change time into human readable format.
# - Replace the syscall number by its name.
#
# It transforms the following audit log lines:
# type=DAEMON_START msg=audit(1730156080.952:7408): op=start ver=3.1.2 format=enriched kernel=4.18.0-553.22.1...
# type=CONFIG_CHANGE msg=audit(1730156080.974:1271): op=set audit_backlog_limit=8192 old=64 auid=4294967295 s...
# type=SYSCALL msg=audit(1730156080.974:1271): arch=c000003e syscall=44 success=yes exit=60 a0=3 a1=7ffc3d897...
# type=PROCTITLE msg=audit(1730156080.974:1271): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6175...
# type=CONFIG_CHANGE msg=audit(1730156080.974:1272): op=set audit_failure=1 old=1 auid=4294967295 ses=4294967...
# type=SYSCALL msg=audit(1730156080.974:1272): arch=c000003e syscall=44 success=yes exit=60 a0=3 a1=7ffc3d897...
# type=PROCTITLE msg=audit(1730156080.974:1272): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6175...
# type=CONFIG_CHANGE msg=audit(1730156080.974:1273): op=set audit_backlog_wait_time=60000 old=60000 auid=4294...
# type=SYSCALL msg=audit(1730156080.974:1273): arch=c000003e syscall=44 success=yes exit=60 a0=3 a1=7ffc3d897...
# type=PROCTITLE msg=audit(1730156080.974:1273): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6175...
# type=SERVICE_START msg=audit(1730156080.980:1274): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u...
# type=AVC msg=audit(1730156101.799:1275): avc:  denied  { write } for  pid=321287 comm="mrtg" name="mrtg" de...
#
#
# Into:
#
# #  1 type=DAEMON_STARTmsg=audit(2024-10-28@18:54:40.952 ID:7408): op=start ver=3.1.2 format=enriched kernel=4.18.0-553.22.1....
# #  2 type=CONFIG_CHANGEmsg=audit(2024-10-28@18:54:40.974 ID:1271): op=set audit_backlog_limit=8192 old=64 auid=4294967295 se...
# #  3 type=SYSCALL      msg=audit(2024-10-28@18:54:40.974 ID:1271) arch=c000003e syscall=sendto          success=yes exit=60 ...
# #  4 type=PROCTITLE    msg=audit(2024-10-28@18:54:40.974 ID:1271): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6...
# #  5 type=CONFIG_CHANGEmsg=audit(2024-10-28@18:54:40.974 ID:1272): op=set audit_failure=1 old=1 auid=4294967295 ses=42949672...
# #  6 type=SYSCALL      msg=audit(2024-10-28@18:54:40.974 ID:1272) arch=c000003e syscall=sendto          success=yes exit=60 ...
# #  7 type=PROCTITLE    msg=audit(2024-10-28@18:54:40.974 ID:1272): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6...
# #  8 type=CONFIG_CHANGEmsg=audit(2024-10-28@18:54:40.974 ID:1273): op=set audit_backlog_wait_time=60000 old=60000 auid=42949...
# #  9 type=SYSCALL      msg=audit(2024-10-28@18:54:40.974 ID:1273) arch=c000003e syscall=sendto          success=yes exit=60 ...
# # 10 type=PROCTITLE    msg=audit(2024-10-28@18:54:40.974 ID:1273): proctitle=2F7362696E2F617564697463746C002D52002F6574632F6...
# # 11 type=SERVICE_STARTmsg=audit(2024-10-28@18:54:40.980 ID:1274): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:...
# # 12 type=AVC          msg=audit(2024-10-28@18:55:01.799 ID:1275): avc:  denied  { write } for  pid=321287 comm="mrtg" name=...
#
#
#  CAUTION: Use this script as a LINE filter.
#           This script does not attempt to carry information across the lines
#           of the processed file. If you want a script that cout the lines of
#           the processed file and prints a line number use the
#           au-log-lineup-count.awk instead.

# ------------------------------------------------------------------------------
# Dependencies
# ------------
#
# - GNU awk  (also implemented as gawk on some systems).


# ------------------------------------------------------------------------------
# Code
# ----
#
# Include the following file that defines the syscall array in a BEGIN clause.
# This file must have been setup prior to invocation of this awk script.
@include "./ausyscall-lookup.awk"

# --
# Every line from the stdin is printed.
# - The lines that start with "type=" are right padded to take 21 characters,
#   because the maximum length of type names is 16: (16 + len('type=') == 21).
# - All other lines are printed unchanged.

BEGIN {
    field_processed=0
}

# Process field 1: the type field
/^type=[A-Z_]+/ {

    # print the first file, padded.
    printf "%-21s", $1;

    # Remember to print all fields after the first.
    field_processed=1
}

# process field 2: the msg=audit field containing the time stamp
$2 ~ /msg=audit([0-9.:]+/ {

    # Extract the seconds, milliseconds and ID in time_elem array.
    time_text=gensub("msg=audit(", "", 1, $2)
    sub( /)/, "", time_text)
    split(time_text, time_elem, "[.:]")

    printf "msg=audit(%s.%s:%s", strftime("%Y-%m-%d@%H:%M:%S", time_elem[1]), time_elem[2], time_elem[3]

    # Remember to print all fields after the second.
    field_processed=2
}

# Process field 4 of SYSCALL records: replace syscall number by its name.
$4 ~ /syscall=[0-9]+/ {

    # Assuming the first 2 fields were processed and printed,
    # print field 3 (the arch field) followed by modified field 4
    printf " %s syscall=%-6s", $3, syscall[gensub("^syscall=", "", 1, $4)];

    # Print the remainder of the line.
    restofline=gensub("^type=[A-Z_]+ msg=audit\\([0-9]+.[0-9]+:[0-9]+\\): arch=[a-z0-9]+ syscall=[0-9]+", "", 1, $0 );
    print restofline

    # All has been printed.
   field_processed=4
}

# Print rest of line if that has not already been done.
field_processed == 2  {

    # Print all fields following the first 2 fields.
    # Instead of trying to loop through all remaining fields and printing them
    # with spaces in between, just compute the remainder and print that. This
    # way we won't inject extra spaces in various locations.
    restofline=gensub("^type=[A-Z_]+ msg=audit\\([0-9.:]+\\)", "", 1, $0 );
    print restofline
}

field_processed == 0   { print }

# ------------------------------------------------------------------------------
