=========================================
USRHOME -- Unix Shell Configuration Files
=========================================

.. image:: https://img.shields.io/:License-gpl3-blue.svg
   :alt: License
   :target: https://www.gnu.org/licenses/gpl-3.0.html

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
USRHOME is not very flexible.

It specifically assumes that:

- Emacs is used, the terminal Emacs is the EDITOR.
- 3 directory trees are managed by USRHOME; *dv*, *dvpub* and *dvpriv*.
- These directories are sub-directories of the *~/my*  directory.


How to Use it
=============

- Clone the repository somewhere.
- Save your shell user configuration files that exist in USRHOME.
- Create symbolic links from your home directory to the corresponding USRHOME
  files listed in the table below.
- Place your original logic not present in USRHOME inside the user-specific
  and user-private scripts USRHOME uses (*more on this later*).


zsh configuration files
-----------------------

========================= ===============================
Location of Symbolic Link Location of the USRHOME file
========================= ================================
``~/.zshenv``             ``~/my/dv/usrhome/dot/``
``~/.zprofile``           ``~/my/dv/usrhome/dot/zprofile``
``~/.zshrc``              ``~/my/dv/usrhome/dot/zshrc``
``~/.zlogin``             ``~/my/dv/usrhome/dot/zlogin``
``~/.zlogout``            ``~/my/dv/usrhome/dot/zlogout``
========================= ================================





.. ---------------------------------------------------------------------------
