===========================
USRHOME augmented commands.
===========================

:Home URL: https://github.com/pierre-rouleau/usrhome
:Created:  Wednesday, June 12 2024.
:Author:  Pierre Rouleau <prouleau001@gmail.com>
:Modified: 2024-06-12 14:27:44, by Pierre Rouleau.
:Copyright: © 2024, Pierre Rouleau


.. contents::  **Table of Contents**
.. sectnum::

.. ---------------------------------------------------------------------------

Overview
========

The directory `USRHOME_DIR/bin/augmented`_ holds a set of command line
scripts that are meant to replace the program with the same name to be able to
force the use of extra command line arguments on the command line.

Each augmented command must first be activated in the shell by invoking the
corresponding `USRHOME_DIR/bin`_\ /envfor-ENV script via its use-ENV command
alias.

The following augmented commands currently exist:

========== ==================== ==============================================
Command    Activation           Purpose
========== ==================== ==============================================
cc_        `use-cc-options`_    Inject compiler options for programs, like GNU
                                make that invoke cc.  See example below.
========== ==================== ==============================================

Examples
========


Augmenting compilation with cc
------------------------------

.. figure::
   ../../res/augmented-cc.png


.. ---------------------------------------------------------------------------
.. links


.. _USRHOME_DIR/bin/augmented: https://github.com/pierre-rouleau/usrhome/tree/main/bin/augmented
.. _USRHOME_DIR/bin:           https://github.com/pierre-rouleau/usrhome/tree/main/ibin
.. _cc:                        https://github.com/pierre-rouleau/usrhome/tree/main/bin/augmented/cc
.. _use-cc-options:            https://github.com/pierre-rouleau/usrhome/tree/main/ibin/envfor-cc-options



.. ---------------------------------------------------------------------------

..
       Local Variables:
       time-stamp-line-limit: 10
       time-stamp-start: "^:Modified:[ \t]+\\\\?"
       time-stamp-end:   "\\.$"
       End:
