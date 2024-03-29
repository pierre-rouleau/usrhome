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
   :target: https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/lang/zsh.pdf

.. image:: https://img.shields.io/badge/Installer_tested_on-macOS_zsh-green
   :target: #how-to-set-it-up

:Author:  Pierre Rouleau
:Copyright: © 2024, Pierre Rouleau

.. ---------------------------------------------------------------------------

USRHOME is a starting project with the goal of holding a set of portable
Unix shell configuration files that can be used in macOS and multiple Linux
distributions under the Z Shell and Bash.

At the moment it supports:

- A basic configuration of zsh for macOS.  It works when zsh is used as the
  default shell, as its the case on macOS since macOS 10.15 Catalina.  It also
  works on older versions of macOS where the older version of Bash is still
  the default shell. On these system just invoke zsh as a sub-shell to use it
  and try the features the older version of zsh provides.  USRHOME works fine
  on those and configures the prompt.

The intent is *not* to provide colourful configurations with fancy fonts and
emoji but just provide a basic environment that will work over several
versions of Operating Systems and will support the Z Shell as well as Bash
running in the default terminal emulator programs provided by the OS.

These are:

- the default macOS Terminal.app,
- the default Linux terminal applications,
- inside Emacs various terminal shell modes,

and work well when used with my `Pragmatic Emacs Library`_ which provides
extensive key bindings for use in these Operating systems and allow extended
use of the `numeric keypad`_.

USRHOME makes one important assumption about the organization of the
directories in your file system: it specifically assumes that:

- The directory that holds the USRHOME directory tree also holds
  a directory tree called ``usrcfg`` that holds the user-specific
  and private configuration information.
  See `The zsh User Configuration File`_ table.

The code supports the Emacs editor, by using the INSIDE_EMACS environment
variable to control the behaviour of some features when they are invoked
inside a shell running inside Emacs.



How to Set it Up
================

- Clone the USRHOME repository somewhere on your home directory tree.
- Open a Z Shell by typing ``zsh`` if you are not already inside a Z Shell.
- Execute the ```setup/setup-usrhome`_`` script **from the root directory
  of the USRHOME depot**:

  - It will print what will be done and prompt before proceeding:

    - Create a ``usrcfg`` directory inside the same directory that
      holds the ``usrhome`` directory.
    - Create the ``usrcfg/setfor-zsh-config.zsh`` file that will
      hold your persistent and private configuration.  At first the file will
      be a copy of a the `usrhome/setup/template/setfor-zsh-config.zsh`_ with
      extra information appended.
    - Finally create symbolic link in your home directory to point
      to the Z Shell configuration files stored inside the `usrhome/dot`_
      directory.  Before proceeding it will create backup of files that are
      already present.

Once that's done you should be able to open a Z Shell with the ``zsh`` command
and see the basic prompt supported by the project and have access to the
commands documented below.

Conventions
===========

- All environment variables used by USRHOME have a name that starts
  with ``USRHOME_``.
- All of those that identify the path of a directory have a name that starts with
  ``USRHOME_DIR_``.



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

``cd-to FNAME``                    cd to the sub-directory that holds the file ``FNAME``.
                                   It reports an error if the file is not found or if more than
                                   one is found.
                                   This command requires the fd_ utility.
``cdv [SUBDIR]``                   cd to the ``/Volumes`` directory or specified ``SUBDIR``.
================================== ================================================================

The following commands change to 4 important directories, and those directories are identified by
environment variables.  The name of these environment variables start with the ``USRHOME_DIR_``
prefix. They are:

USRHOME_DIR_MY:
  The directory where all your development directories are located.  It is
  often different from ``HOME`` on systems like macOS; it could
  be ``$HOME/Documents`` if you want your files replicated by
  Apple iCloud or another directory, like ``$HOME/my`` if you do
  not want them replicated and stored in the iCloud.

USRHOME_DIR_DV:
  The directory where you store your main, or most-active, development sub-directories.
  For example on my systems I often have a ``~/code`` or ``~/my/code`` or ``~/my/dv``
  directory where I place my most active projects (or symlinks to these directories).
  This can be located anywhere.

USRHOME_DIR_PRIV:
  The directory where you store your *private* development sub-directories.
  That could be something you do not want to publish because it's not ready, or
  it could be the directories for your various contract work.
  This can be located anywhere.

USRHOME_DIR_PUB:
  The directory where you store your secondary, *public*, sub-directories.
  That could hold a set of repositories that are forks of other projects
  to which you contribute, or libraries and tools you want to build yourself,
  anything you do not consider your main or most-active development.
  This can be located anywhere.

These environment variables are defined in the user persistent configuration file:
usrcfg/setfor-zsh-config.zsh.  The `setup/setup-usrhome`_ script initializes them
to the value stored in `usrhome/setup/template/setfor-zsh-config.zsh`_ template file.

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``cdh [SUBDIR]``                   cd to the directory identified by ``USRHOME_DIR_MY``
                                   or its identified ``SUBDIR``.

``cddv [SUBDIR]``                  cd to the directory identified by ``USRHOME_DIR_DV``
                                   or its identified ``SUBDIR``.

``cddpriv [SUBDIR]``               cd to the directory identified by ``USRHOME_DIR_PRIV``
                                   or its identified ``SUBDIR``.

``cddpub [SUBDIR]``                cd to the directory identified by ``USRHOME_DIR_PUB``
                                   or its identified ``SUBDIR``.
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

Project Startup Commands
~~~~~~~~~~~~~~~~~~~~~~~~

================================== ================================================================
USRHOME Command Name               Description
================================== ================================================================
``pel [SUBDIR]``                   Change current directory to PEL_ depot directory or its SUBDIR
                                   if specified.
                                   Set terminal title to 'PEL'.

``usrhome [SUBDIR]``               Change current directory to USRHOME depot directory
                                   or its SUBDIR if specified.
                                   Set terminal title to 'USRHOME'.

``usrcfg [SUBDIR]``                Change current directory to the USRHOME personal/persistent
                                   configuration directory, usrcfg
                                   or its SUBDIR if specified.
                                   Set terminal title to 'USRHOME:usrcfg'
================================== ================================================================


The Prompt
~~~~~~~~~~

The zsh prompt
^^^^^^^^^^^^^^

USRHOME sets up a basic Z Shell prompt that does not need any zsh extension
library. The default prompt shows:

- A leading '>' character,
- the exit code of the last command, in decimal,
- current time in 24-hour HH:MM:SS format,
- the shell nested level, prefixed with 'L',
- optional user-name @ host-name,
- the last 3 directory components of the current directory,
- the last character is '#' if the current user has root privilege,
  otherwise the '%' character is used.

When there is enough room, the right side prompt (RPROMPT) is shown with:

- The full path of the current directory.
- If the current directory is inside a Git or Mercurial repository, the
  repository branch and repository name.  In a Mercurial repository the 'hg:'
  prefix is included.

An example is shown here:


.. figure:: res/zsh-prompt-01.png




Command and Script Organization
-------------------------------

USRHOME provides several types of command and scripts, as listed here.

============================= ================== =================================================
Name format of scripts        Type of script     Purpose
============================= ================== =================================================
``USRHOME/ibin/do-CMD``       Sourced script     Meant to be invoked by alias command ``CMD``
``USRHOME/ibin/setfor-CMD``   Sourced script     Meant to be invoked by alias command ``CMD``
``USRHOME/ibin/envfor-ENV``   Sourced script     Meant to be invoked by alias command ``use-ENV``
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
.. _Pragmatic Emacs Library:                      https://github.com/pierre-rouleau/pel#readme
.. _numeric keypad:                               https://raw.githubusercontent.com/pierre-rouleau/pel/master/doc/pdf/numkeypad.pdf
.. _fd:                                           https://github.com/sharkdp/fd
.. _ setup/setup-usrhome:                         https://github.com/pierre-rouleau/usrhome/blob/main/setup/setup-usrhome
.. _usrhome/setup/template/setfor-zsh-config.zsh: https://github.com/pierre-rouleau/usrhome/blob/main/setup/template/setfor-zsh-config.zsh
.. _usrhome/dot:                                  https://github.com/pierre-rouleau/usrhome/tree/main/dot

.. ---------------------------------------------------------------------------
