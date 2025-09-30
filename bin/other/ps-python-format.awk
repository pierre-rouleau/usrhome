# AWK FILE: ps-python-format.awk
#
# Purpose   : EXtract Python process from psl-list putput.
# Created   : Tuesday, September 30 2025.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2025-09-30 07:58:47 EDT, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
# The purpose of this script is to take the output of the command
#
#     ps-list python
#
# that prints lines like this:
#
#   01  7464  7448   0  7:12am ttys003    0:00.05 /Library/Frameworks/Python.framework/Versions/3.13/Resources/Python.app/Contents/MacOS/Python -i
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
# The script extract the PPID of the Python process, finds the
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
$8~/[Pp]ython/{
      command = "pidcwd " $2
      command |& getline path_result
      close(command)
      print $0, "  ▶︎▶︎▶︎ CWD: ", path_result
}

# ------------------------------------------------------------------------------
