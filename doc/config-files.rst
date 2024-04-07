=========================
Shell Configuration Files
=========================

:Home URL:
:Project:
:Created:  Sunday, April  7 2024.
:Author:  Pierre Rouleau <prouleau001@gmail.com>
:Modified: 2024-04-07 12:59:19, by Pierre Rouleau.
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
======================= ========================================= ========================

Typically the ``~/.bash_profile`` file contains the line::

  if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

after (or before) any login-specific initializations.


When used non-interactively, such as when a Bash script is used,
Bash behaves as if the following command was executed, without
PATH being searched::

  if [ -n "$BASH_ENV" ]; then . "$BASH_ENV"; fi


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
