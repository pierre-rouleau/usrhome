======================================================
Purpose of the USRHOME/bin/sub-ssh4 - Base SSH scripts
======================================================

:Home URL: https://github.com/pierre-rouleau/usrhome
:Created:  Friday, September 27 2024.
:Author:  Pierre Rouleau <prouleau001@gmail.com>
:Modified: 2024-10-11 12:24:01 EDT, updated by Pierre Rouleau.
:Copyright: © 2024, Pierre Rouleau


.. contents::  **Table of Contents**
.. sectnum::

.. ---------------------------------------------------------------------------

Overview
========

The ``bin/sub-ssh4`` directory holds a set of *base* source scripts that
implement the logic for several SSH utilities.  These base scripts are meant
to be invoked by top-level scripts or shell functions that provide the details
required to complete the implementation.

The directory holds the following files.

================= =============================================================
File              Purpose
================= =============================================================
envfor-cmds       Common logic used by the other files: checks the command
                  line arguments, extract their value, storing them into the
                  following shell variables:

                  - pgm_name : Name of the executing command
                  - ipv4addr : The IP address (currently only IPv4 is supported)
                  - hostname : The host name of the remote computer system
                  - username : The user name on that remote computer system

from-remote       Holds the logic to copy a remote computer file to the
                  current local directory using SSH.

from-remote-dir   Holds the logic to copy a remote computer directory to the
                  current local directory using SSH.

ssh4-scoped       Holds the logic to establish a SSH connection to a computer
                  specified by the various ``USRHOME_SSH4__`` environment
                  variables.

to-remote         Holds logic to copy a local file to a remote computer using
                  SSH.

to-remote-dir     Holds logic to copy a local directory to a remote computer
                  using SSH.
================= =============================================================


These commands use the following environment variables to identify the target
computer:

======================= ================================================
Variable Name           Purpose
======================= ================================================
USRHOME_SSH4__PGM_NAME  Name of the executing command (the script name)
USRHOME_SSH4__IPV4ADDR  The IP address (currently only IPv4 is supported)
USRHOME_SSH4__HOSTNAME  The host name of the target system
USRHOME_SSH4__HOMEROOT  The root directory for "~" in the target system.
                        If the target system user home directory is
                        something like "/root", then this is an empty
                        string.
USRHOME_SSH4__USERNAME  The user name on that target system
======================= ================================================

Top-level Command Templates
===========================

SSH Commands
------------

The SSH commands are relatively simple and can be implemented as complete
file-bound scripts or as shell functions.

ssh4-TARGET commands
~~~~~~~~~~~~~~~~~~~~

The ``ssh4-`` commands establish a SSH connection to the target specified by
the various ``USRHOME_SSH4__`` environment variables (see above).

The easiest way to implement these are shell level functions stored inside a
script that is sourced by the system.  A good location for such a script is
inside the ``$USRCFG/setfor-all-config.sh`` or a project specific sourced
script.  Here's an example of the required function code, where the user's
home directory in the remote computer is "/home/diana":


.. code:: sh

    ssh4-iMac2-msl12-1-10-a-root()
    {
        export USRHOME_SSH4__PGM_NAME="ssh4-my-server"
        export USRHOME_SSH4__HOSTNAME="my-server"
        export USRHOME_SSH4__HOMEROOT="/home"
        export USRHOME_SSH4__USERNAME="diana"
        export USRHOME_SSH4__IPV4ADDR="192.168.0.100"

        ssh4__remote "my-server" "$@"
    }

The code first exports the required environment variables that will be used
the `${USRHOME_DIR}/bin/sub-ssh4/ssh4-scoped`_ script.

Then it calls the ``ssh4__remote()`` shell function defined by the
`${USRHOME_DIR}/dot/bashrc.bash`_ or the `${USRHOME_DIR}/dot/zshrc.zsh`_ shell
configuration files, passing the title for the terminal window and then
the arguments specified by the user.


scp Commands
------------

It is best to implement the target specific scp commands as scripts instead of
shell functions. Why? Because you can refer to shell accessible commands
inside other tools such as Emacs.  Launching a scp command to copy a file or
directory to a remote computer can be done from `Emacs Dired`_.  With Dired_, you
can select several files (or directories) and issue the command on all of
these selected items.  All these will be executed sequentially.

See `PEL Dired PDF`_ for more information.

scp4-from-TARGET
~~~~~~~~~~~~~~~~

The ``scp4-from-TARGET`` commands copy a file from the remote computer to the
current local directory using scp.  The various ``USRHOME_SSH4__`` environment
variables (see above) identify the remote target.

The top-level script should be something like this:

.. code:: sh

  #!/bin/sh

  export USRHOME_SSH4__HOSTNAME="my-server"
  export USRHOME_SSH4__HOMEROOT="/home"
  export USRHOME_SSH4__USERNAME="diana"
  export USRHOME_SSH4__IPV4ADDR="192.168.0.100"
  USRHOME_SSH4__PGM_NAME="$(basename "$0")"
  export USRHOME_SSH4__PGM_NAME

  "${USRHOME_DIR}/bin/sub-ssh4/from-remote" "$@"

scp4-from-TARGET-dir
~~~~~~~~~~~~~~~~~~~~

The ``scp4-from-TARGET-dir`` commands copy a directory from the remote computer to the
current local directory using scp.  The various ``USRHOME_SSH4__`` environment
variables (see above) identify the remote target.

The top-level script should be something like this:

.. code:: sh

  #!/bin/sh

  export USRHOME_SSH4__HOSTNAME="my-server"
  export USRHOME_SSH4__HOMEROOT="/home"
  export USRHOME_SSH4__USERNAME="diana"
  export USRHOME_SSH4__IPV4ADDR="192.168.0.100"
  USRHOME_SSH4__PGM_NAME="$(basename "$0")"
  export USRHOME_SSH4__PGM_NAME

  "${USRHOME_DIR}/bin/sub-ssh4/from-remote-dir" "$@"


scp4-to-TARGET
~~~~~~~~~~~~~~

The ``scp4-to-TARGET`` commands copy a local file to the remote
computer using scp.  The various ``USRHOME_SSH4__`` environment variables (see
above) identify the remote target.

This script supports the following two optional environment variables which
might help when a tool like `Dired`_ is used to copy several files in one
shot.  For example copying the files from a local directory tree to a
directory tree located on a remote computer in the same relative positions in
the trees.

The extra optional environment variables are:

======================= ================================================
Variable Name           Purpose
======================= ================================================
USRHOME_SSH4__LOC_DIR   Reference directory tree root on local computer. Defaults to '.'
USRHOME_SSH4__REM_DIR   Equivalent directory tree root on remote computer.
======================= ================================================

These extra environment variable are typically *not* set by the script;
instead they are set by the user manually or in the shell environment to set
the relationship between a directory tree in the local computer and the
corresponding directory tree in the remote computer.



The top-level script should be something like this:

.. code:: sh

  #!/bin/sh

  export USRHOME_SSH4__HOSTNAME="my-server"
  export USRHOME_SSH4__HOMEROOT="/home"
  export USRHOME_SSH4__USERNAME="diana"
  export USRHOME_SSH4__IPV4ADDR="192.168.0.100"
  USRHOME_SSH4__PGM_NAME="$(basename "$0")"
  export USRHOME_SSH4__PGM_NAME


  "${USRHOME_DIR}/bin/sub-ssh4/to-remoter" "$@"

scp4-to-TARGET-dir
~~~~~~~~~~~~~~~~~~

The ``scp4-to-TARGET-dir`` commands copy a local directory to the remote
computer using scp.  The various ``USRHOME_SSH4__`` environment variables (see
above) identify the remote target.

The top-level script should be something like this:

.. code:: sh

  #!/bin/sh

  export USRHOME_SSH4__HOSTNAME="my-server"
  export USRHOME_SSH4__HOMEROOT="/home"
  export USRHOME_SSH4__USERNAME="diana"
  export USRHOME_SSH4__IPV4ADDR="192.168.0.100"
  USRHOME_SSH4__PGM_NAME="$(basename "$0")"
  export USRHOME_SSH4__PGM_NAME

  "${USRHOME_DIR}/bin/sub-ssh4/to-remote-dir" "$@"

.. ---------------------------------------------------------------------------
.. links


.. _Emacs Dired:
.. _Dired:                                   https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html#Dired
.. _PEL Dired PDF:                           https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/mode-dired.pdf
.. _${USRHOME_DIR}/bin/sub-ssh4/ssh4-scoped: https://github.com/pierre-rouleau/usrhome/blob/main/bin/sub-ssh4/ssh4-scoped
.. _${USRHOME_DIR}/dot/bashrc.bash:          https://github.com/pierre-rouleau/usrhome/blob/main/dot/bashrc.bash#L537
.. _${USRHOME_DIR}/dot/zshrc.zsh:            https://github.com/pierre-rouleau/usrhome/blob/main/dot/zshrc.zsh#L384



.. ---------------------------------------------------------------------------

..
       Local Variables:
       time-stamp-line-limit: 10
       time-stamp-start: "^:Modified:[ \t]+\\\\?"
       time-stamp-end:   "\\.$"
       End:
