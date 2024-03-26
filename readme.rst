=========================================
USRHOME -- Unix Shell Configuration Files
=========================================

.. image:: https://img.shields.io/:License-gpl3-blue.svg
   :alt: License
   :target: https://www.gnu.org/licenses/gpl-3.0.html

.. image:: https://img.shields.io/badge/State-Under_Development-yellow
   :alt: Version
   :target: https://github.com/pierre-rouleau/usrhome

:Author:  Pierre Rouleau
:Copyright: © 2024, Pierre Rouleau


.. contents::  **Table of Contents**
.. sectnum::

.. ---------------------------------------------------------------------------

USRHOME is a starting project with the goal of holding a set of portable
Unix shell configuration files.  At first it will support Bash and the Z
shell.

This early version of the files make several assumptions as to where some
files and directories are located. As USRHOME evolves, most of these will
become configurable making USRHOME more flexible.  At this very early stage
USRHOME is not very flexible.  However, this constitutes a set of shell
configuration files I can use in multiple computers.

It specifically assumes that:

- The directory that holds the USRHOME directory tree also holds
  a directory tree called ``usrcfg`` that holds the user-specific
  and private configuration information.
  See `The zsh User Configuration File`_ table.
- Emacs is used, the terminal Emacs is the EDITOR.
- 3 directory trees are managed by USRHOME: *~/my/dv*, *~/my/dvpub* and *~/my/dvpriv*.


How to Use it
=============

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

========================= ===================================
Location of Symbolic Link Location of the USRHOME file
========================= ===================================
``~/.zshenv``             ``~/my/dv/usrhome/dot/zshenv.zsh``
``~/.zprofile``           ``~/my/dv/usrhome/dot/zprofile.zsh``
``~/.zshrc``              ``~/my/dv/usrhome/dot/zshrc.zsh``
``~/.zlogin``             ``~/my/dv/usrhome/dot/zlogin.zsh``
``~/.zlogout``            ``~/my/dv/usrhome/dot/zlogout.zsh``
========================= ===================================


The zsh User Configuration File
-------------------------------

=========================== ===============================================
Environment Variable Name   Purpose
=========================== ===============================================
USRHOME_ECHO                Set to 1 to activate tracing of the configuration
                            file sourcing.
USRHOME_USE_HOMEBREW        Set to 1 when using Homebrew, to add Homebrew
                            directories to the PATH.
=========================== ===============================================

.. ---------------------------------------------------------------------------
