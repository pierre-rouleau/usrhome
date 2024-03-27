=========================================
USRHOME -- Unix Shell Configuration Files
=========================================

.. image:: https://img.shields.io/:License-gpl3-blue.svg
   :alt: License
   :target: https://www.gnu.org/licenses/gpl-3.0.html

.. image:: https://img.shields.io/badge/State-Unstable_early_development-red
   :alt: Version
   :target: https://github.com/pierre-rouleau/usrhome

.. image:: https://img.shields.io/badge/Supports-macOS_zsh-green
   :alt: Version
   :target: https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/lang/zsh.pdf


:Author:  Pierre Rouleau
:Copyright: © 2024, Pierre Rouleau

.. ---------------------------------------------------------------------------

USRHOME is a starting project with the goal of holding a set of portable
Unix shell configuration files that can be used in macOS and multiple Linux
distributions.  At first it will support Bash and the Z shell.

The intent is not to provide colourful configurations with fancy fonts and
emoji but allow its use in:

- the default macOS Terminal.app,
- the default Linux terminal applications,
- inside Emacs various terminal shell modes,

and work well when used with my `Pragmatic Emacs Library`_ which provides
extensive key bindings for use in these Operating systems and allow extended
use of the `numeric keypad`_.

In this early version of USRHOME I focus on macOS zsh and make several
assumptions as to where some files and directories are located. As USRHOME
evolves, I will add support for Bash on macOS and Linux and then complete zsh
support for Linux.
Also I'm going to make USRHOME more configurable and flexible.
At this very early stage USRHOME is not very flexible.  However, this
constitutes a set of shell configuration files I can use in multiple
computers.

It specifically assumes that:

- The directory that holds the USRHOME directory tree also holds
  a directory tree called ``usrcfg`` that holds the user-specific
  and private configuration information.
  See `The zsh User Configuration File`_ table.
- Emacs is used, the terminal Emacs is the EDITOR.
- 3 directory trees are managed by USRHOME: *~/my/dv*, *~/my/dvpub* and *~/my/dvpriv*.

How to Set it Up
================

- Clone the USRHOME repository somewhere on your home directory tree.
- Create a ``usrcfg`` directory inside the same directory that holds the
  ``usrhome`` directory.

  - Create the ``usrcfg/setfor-zsh-config.zsh`` file.  That file will be
    sourced during the Z Shell startup by ``~/.zprofile``.  Inside that file
    export one or several of the environment variables described in
    `The zsh User Configuration File`_ table.

- Save your shell user configuration files that exist in USRHOME.
- Create symbolic links from your home directory to the corresponding USRHOME
  files listed in the table below.
- Place your original logic not present in USRHOME inside the user-specific
  and user-private scripts USRHOME uses (*more on this later*).


zsh configuration files
-----------------------

========================= =====================================================
Location of Symbolic Link Location of the USRHOME files pointed by the symlinks
========================= =====================================================
``~/.zshenv``             ``~/my/dv/usrhome/dot/zshenv.zsh``
``~/.zprofile``           ``~/my/dv/usrhome/dot/zprofile.zsh``
``~/.zshrc``              ``~/my/dv/usrhome/dot/zshrc.zsh``
``~/.zlogin``             ``~/my/dv/usrhome/dot/zlogin.zsh``
``~/.zlogout``            ``~/my/dv/usrhome/dot/zlogout.zsh``
========================= =====================================================


The zsh User Configuration File
-------------------------------

=============================== =================================================
Environment Variable Name       Purpose
=============================== =================================================
USRHOME_TRACE_SHELL_CONFIG      Set to 1 to activate tracing of the configuration
                                file sourcing.
                                Use the ``usrhome-shell-toggle-tracing``
                                command to
                                toggle this in the current shell.

USRHOME_PROMPT_SHOW_USR_HOST    Set to 1 to display user name and host name
                                in the prompt.
                                Use the ``usrhome-prompt-toggle-usr-host``
                                command to
                                toggle this in the current shell.

USRHOME_USE_HOMEBREW            Set to 1 when using Homebrew, to add Homebrew
                                directories to the PATH.
=============================== =================================================


USRHOME Commands and Scripts
----------------------------

Shell Behavior Control
~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``usrhome-shell-toggle-tracing``   Toggle tracing the execution of the shell configuration files
                                   when a shell starts.
``usrhome-prompt-toggle-usr-host`` Toggle the inclusion of the user name and host name inside
                                   the prompt.
================================== ================================================================

Shell Status Info
~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``ss``                             Show current and default shell environment variable names
                                   and values.
================================== ================================================================

Terminal Window Control
~~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``settitle``                       Set the time to the value passed as its first parameter.
                                   Only accepts 1 parameter, so if you want to set the title with
                                   embedded spaces just quote the entire title.
================================== ================================================================

Directory Navigation
~~~~~~~~~~~~~~~~~~~~

Extensions to the ``cd`` command.

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``..``                             Alias to ``cd ..``
``...``                            Alias to ``cd ../..``
``....``                           Alias to ``cd ../../..``
``cddusrhome [dir]``               cd to the USRHOME directory or specified sub-directory.
``cdh [dir]``                      cd to the ``~/my`` directory or specified sub-directory.
``cdv [dir]``                      cd to the ``/Volumes`` directory or specified sub-directory.
``cddv [dir]``                     cd to the ``/my/dv`` directory or specified sub-directory.
``cddpriv [dir]``                  cd to the ``/my/dvpriv`` directory or specified sub-directory.
``cddpub [dir]``                   cd to the ``/my/dvpub`` directory or specified sub-directory.
``cd-to FNAME``                    cd to the sub-directory that holds the file FNAME.
                                   It reports an error if the file is not found or if more than
                                   one is found.
                                   This command requires the fd_ utility.
================================== ================================================================

Listing Files/Directories/Links
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``l``                              Colorized ls that also shows the file type symbol.
``la``                             Same as ``l`` but also show hidden files.
``ll``                             ``ls -l`` with colorized and  file type symbols.
``lla``                            Same as ``ll`` but also show hidden files.
``lt``                             ``ls -ltr`` with colorized and  file type symbols.
``lta``                            Same as ``lt`` but also show hidden files.
``lsd``                            List sub-directories in current directory.
``lsl``                            List symbolic links in current directory.
================================== ================================================================

Environment Variables Commands
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``clrenv VARNAME``                 Clear (remove) the environment variable specified by name from
                                   the environment of the *current* shell.

``setenv VARNAME VALUE``           Set the environment variable named VARNAME to the specified
                                   VALUE and inject it inside the *current* shell.

``showpath [-n]``                  Print the value of PATH, placing each directory in its own line.
                                   With the optional ``-n``: print a left justified number on
                                   each line.

================================== ================================================================


Miscellaneous Commands
~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``cls``                            Shortcut for ``clear``; clear the content of the shell window.
``md``                             Shortcut for ``mkdir``
``p3``                             Shortcut for ``python3``
================================== ================================================================

Programming Environment Setup
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``pel``                            Change to the PEL_ development directory. Sets terminal title.
================================== ================================================================


Command and Script Organization
-------------------------------

USRHOME provides several types of command and scripts, as listed here.

============================= ================== =================================================
Name format of scripts        Type of script     Purpose
============================= ================== =================================================
``USRHOME/bin/do-CMD``        Sourced script     Meant to be invoked by alias command ``CMD``
``USRHOME/bin/setfor-CMD``    Sourced script     Meant to be invoked by alias command ``CMD``
``USRHOME/bin/envfor-ENV``    Sourced script     Meant to be invoked by alias command ``use-ENV``
``USRHOME/bin/...``           Shell script       A regular script that can be invoked directly.
============================= ================== =================================================

The commands alias are all sourcing a sourced script that *injects* or *modifies*
something inside the current running shell.  The source scripts all have names
that start with one of the identified prefixes: ``setfor-`` or ``envfor-``.

The ``setfor-`` sourced scripts are used by various USRHOME commands that
control the shell, such as ``usrhome-shell-toggle-tracing`` and
``usrhome-prompt-toggle-usr-host``.

The ``envfor-ENV`` sourced scripts are used by the equivalent ``use-ENV``
command.  These commands set the shell for the environment identified by the
``ENV`` suffix.  The idea is that when you start a shell it comes with a
minimal environment.  You can then activate a given environment by issuing the
corresponding ``use-`` command.  For example, assuming that you want to use
various tools for the Erlang, Factor, Rust or Zig programming languages but
separately, in each shells, you would use the ``use-erlang``, ``use-factor``,
``use-rust`` and ``use-zig`` commands that source their corresponding source
scripts that update the PATH and other environment variables that are
necessary for the environment.

As USRHOME grows, I will be adding several of these environment setting
scripts and commands to support various Operating Systems.

.. ---------------------------------------------------------------------------
.. links


.. _PEL:
.. _Pragmatic Emacs Library: https://github.com/pierre-rouleau/pel#readme
.. _numeric keypad:          https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/numkeypad.pdf
.. _fd:                      https://github.com/sharkdp/fd

.. ---------------------------------------------------------------------------
