=========================
Shell Configuration Files
=========================

:Home URL:
:Project:
:Created:  Sunday, April  7 2024.
:Author:  Pierre Rouleau <prouleau001@gmail.com>
:Modified: 2024-04-10 16:13:10 EDT, updated by Pierre Rouleau.
:Copyright: © 2024, Pierre Rouleau


.. contents::  **Table of Contents**
.. sectnum::

.. ---------------------------------------------------------------------------


Bash Configuration Files
========================

:Ref: `Bash Startup Files @ Bash Manual`_

======================= ========================================= ========================
Interactive login shell Interactive, non-login shell              Non interactive
======================= ========================================= ========================
- /etc/profile          - ~/.bashrc (unless --norc option is used Uses ``BASH_ENV``
- ~/.bash_profile
- ~/.bash_login
- ~/.profile
- ~/.bash_logout
======================= ========================================= ========================


**Startup**:

================= ====================== ==================
Operating System  On Terminal startup    On Bash sub-shell
================= ====================== ==================
macOS             - ``~/.bash_profile``  - `` ~/.bashrc``

                    - ``~/.bashrc``

Ubuntu Linux      - ``~/.bashrc``        - `` ~/.bashrc``
================= ====================== ==================

- On macOS:

  - On macOS, the ``~/.bash_profile" is executing first and it sources
    the ``~/.bashrc``.  Since the ``~/.bashrc`` file is sourced again
    when a Bash sub-shell is launched, it's possible to place all logic
    that must be executed once inside the ``~/.bash_profile"; for example
    the building of the PATH environment variable.

  - When Opening a new terminal, that uses Bash as the default shell, the
    following files are sourced:

    - ~/.bash_profile  (the code of that file normally also sources
      ``~/.bashrc``)

  - When typing ``bash`` to open a Bash sub-shell,
    Note that the ``~/.bashrc`` is executed again.

- On Ubuntu Linux, the only user-controlled file sourced in ``~/.bashrc``.
  The ``/etc/profile`` file holds the logic for all users and that sets the
  PATH environment variable.  The ``~/.bashrc`` normally inherits the PATH
  and if logic is required to modify PATH it must use an environment variable
  to prevent executing that logic again when a sub-shell runs ``~/.bashrc``
  again.



Typical ~/.bash_profile
-----------------------

The ``~/.bash_profile`` file is not always used.  Several Linux
distributions do not use it.  Others have it and do not have the
``~/.profile`` file instead.


When it is used, typically the ``~/.bash_profile`` file contains the line::

  if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

after (or before) any login-specific initializations.


When used non-interactively, such as when a Bash script is used,
Bash behaves as if the following command was executed, without
PATH being searched::

  if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi

The ~/.profile
--------------

This is the POSIX ``sh`` configuration file.

Some Linux distributions have it, like Debian, Ubuntu and Kali, but others do not have
it, like Fedora.

The content is often the same, as shown here::

      # ~/.profile: executed by the command interpreter for login shells.
      # This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
      # exists.
      # see /usr/share/doc/bash/examples/startup-files for examples.
      # the files are located in the bash-doc package.

      # the default umask is set in /etc/profile; for setting the umask
      # for ssh logins, install and configure the libpam-umask package.
      #umask 022

      # if running bash
      if [ -n "$BASH_VERSION" ]; then
          # include .bashrc if it exists
          if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
          fi
      fi

      # set PATH so it includes user's private bin if it exists
      if [ -d "$HOME/bin" ] ; then
          PATH="$HOME/bin:$PATH"
      fi

      # set PATH so it includes user's private bin if it exists
      if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
      fi

When the file is not available, I suspect the POSIX sh to be implemented as
bash, as GNU bash is able to simulate the POSIX sh. That is described in Bash
man.  In that case the ``~/.bash_profile`` file is used and as described in
the previous section it often simply sources the ``~/.bashrc`` file.

The ~/.bash_logout
------------------

The ``~/.bash_logout`` is normally not used in macOS, even in the older
versions that use the older version of Bash as the default shell.

The file is used on Linux distributions  and often hold the following code::

          # ~/.bash_logout: executed by bash(1) when login shell exits.

          # when leaving the console clear the screen to increase privacy

          if [ "$SHLVL" = 1 ]; then
          [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
          fi

The ~/.bashrc
-------------

In all Linux distributions I have seen so far, the ``~/.bashrc`` file holds
the Bash configuration logic.

- The ``~/.bash_profile``, when present, simply source the ``~/.bashrc`` if present.
- The ``~/.profile``, when running under Bash, sources the ``~/bashrc`` file
  if it exists. In all shells it then appends ``~/.local/bin`` and ``~/bin``
  to the PATH if these directories exists.

Z Shell Configuration Files
===========================

:Ref: The `Z Shell PDF`_, which shows all files used by the ZShell

See the reference listed above for a complete list.

The following diagram shows the user configuration files and
how USRHOME deals with them:

.. figure:: ../res/zsh-startup-01.png

.. ---------------------------------------------------------------------------
.. links


.. _Bash Startup Files @ Bash Manual: https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html
.. _Z Shell PDF: https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/lang/zsh.pdf



.. ---------------------------------------------------------------------------

..
       Local Variables:
       time-stamp-line-limit: 10
       time-stamp-start: "^:Modified:[ \t]+\\\\?"
       time-stamp-end:   "\\.$"
       End:
