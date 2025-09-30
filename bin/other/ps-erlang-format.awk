# AWK FILE: ps-erlang-format.awk
#
# Purpose   : EXtract Erlang process from psl-list putput.
# Created   : Tuesday, September 30 2025.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2025-09-30 08:06:58 EDT, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# The purpose of this script is to take the output of the command
#
#     ps-list erlang
#
# that prints lines like this:
#
#   501  7527  7448   0  7:14am ttys004    0:00.35 /opt/homebrew/Cellar/erlang/28.0.2_1/lib/erlang/erts-16.0.2/bin/beam.smp -- -root /opt/homebrew/Cellar/erlang/28.0.2_1/lib/erlang -bindir /opt/homebrew/Cellar/erlang/28.0.2_1/lib/erlang/erts-16.0.2/bin -progname erl -- -home /Users/roup -- -newshell --
#
# where the columns are:
# 1   UID  : user ID
# 2   PID  : process ID
# 3   PPID : Parent process ID
# 4   C    : CPU utilization of process or thread
# 5   STIME: system CPU time
# 6   TTY  : controlling terminal
# 7   TIME : total CPU time (user + system) since it started
# 8   CMD  : command
#
# The script extract the PPID of the Erlang process, finds the
# current working directory of the process and appends it to the line.
#
# To extract the current working directory of a process ID, we use
# lsof and AWK again:
#
#   lsof -a -d cwd -p $PPID -n -Fn | awk '/^n/ {print substr($0,2)}'
#
# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# This is a GNU AWK script.  It does not work on regular AWK.
#

# ------------------------------------------------------------------------------
# Code
# ----
#
#
$8~/erlang/{
      command = "pidcwd " $2
      command |& getline path_result
      close(command)
      print $0, "  ▶︎▶︎▶︎ CWD: ", path_result
}

# ------------------------------------------------------------------------------
