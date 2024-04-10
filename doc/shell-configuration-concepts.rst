============================
Shell Configuration Concepts
============================

:Created:  Wednesday, April 10 2024.
:Author:  Pierre Rouleau <prouleau001@gmail.com>
:Modified: 2024-04-10 16:17:57, by Pierre Rouleau.
:Copyright: © 2024, Pierre Rouleau


.. note:: This file contains a collection of thoughts about the upcoming
          design of USRHOME.


.. contents::  **Table of Contents**
.. sectnum::

.. ---------------------------------------------------------------------------


Concepts
========

- USRHOME Infrastructure

  - Settings available everywhere
  - Commands available everywhere

- General User Specific Configuration


- OS Specific

  - Selection of set of commands available only on some OS.
  - Selection of an implementation that differ depending of the OS
  - The criteria may be:

    - the OS family: identified by ``uname``: 'Darwnin', 'Linux', etc...
    - hardware platform:  ``uname -m``: x86_64, arm64, aarch64, etc...

- User Specific

  - Special secret configuration data may be stored in user-specific files,
    whose location are standardized using the ``$USER`` environment variable
    value to identify a user-specific directory.  The user can use symlinks
    to store the file somewhere else if required.

- Host Specific

  - In some cases, host-specific configuration may be required.

- Project Specific

  - All configurations are essentially grouped by *projects*:

    - There is the default *project*, which corresponds to the default shell
     configuration.
    - Each major activity is identified by a specific *project* (or activity).
      A *project* specializes the shell for working on a specific set of files
      and using a specific set of tools.
    - The *projects* are configured by writing a  ``envfor-ENV`` sourceable
      script and assigning a ``use-ENV`` alias for it.  The ``envfor-ENV``
      file for a specific project can then source a specific set of
      ``envfor-ENV`` that are specialized for setting the environment for
      specific tools.

- Tool Specific

  - Once a tool is installed, if this tool require a modification to the shell
    environment, it's best to move that logic inside a tool-specific
    ``envfor-ENV`` file.  That file can hold comments describing what was done
    to add support for the tool.  If modification or additions to the
    environment is required, the file holds that logic.

    - A corresponding ``use-ENV`` command alias can be created to bring these
      inside a shell from the command line.

.. ---------------------------------------------------------------------------

USRHOME Implementation
======================

The USRHOME project implements the infrastructure helping the implementation
of the concepts described in the previous section.  USRHOME does *not* provide
the user-specific logic.

The user must create a set of files located in the ``usrcfg`` directory that
are sourced by USRHOME files.

USRHOME does provide examples of potential user files, located in a directory
tree that mimics what would be stored inside the ``usrcfg`` directory tree.

.. ---------------------------------------------------------------------------

..
       Local Variables:
       time-stamp-line-limit: 10
       time-stamp-start: "^:Modified:[ \t]+\\\\?"
       time-stamp-end:   "\\.$"
       End:
