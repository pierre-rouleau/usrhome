# Sourced script: sanitize-path.zsh  -*- mode: sh; -*-
#
# Purpose   : PATH sanitizer for Zsh.
# Created   : Friday, November  6 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-08 10:36:07 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Sanitize path variable - Zsh compliant.
# Functions only. Sourcing this file does not sanitize a variable.
#

# - PATH is the most fundamental environment variable in operating systems
#   like Linux, macOS, and Windows. It contains a colon-separated
#   (semicolon-separated on Windows) list of directory paths that the system
#   searches, from left to right, to find executable files when you type a
#   command.
#
# - MANPATH: An ordered list of directories where the man command searches for
#   manual (man) pages.
#
# - LD_LIBRARY_PATH (or DYLD_LIBRARY_PATH on macOS): An ordered list of
#   directories where the dynamic linker/loader looks for shared libraries
#   (.so or .dylib files) at runtime before checking default system locations.
#
# - CDPATH: A colon-separated list of directories used as search paths by the
#   cd (change directory) shell command, letting you jump to subdirectories
#   inside those base paths from anywhere.
#
# - INFOPATH: A list of directories searched by the info command-line
#   documentation reader for Texinfo documents.
#
# - PKG_CONFIG_PATH: A list of directories where pkg-config looks for .pc
#   metadata files to find compiler and linker flags for development
#   libraries.
#
# - PYTHONPATH: A list of directory paths that the Python interpreter adds to
#   sys.path to look for imported modules and packages.
#
# - CLASSPATH: Used by Java to specify the locations of class files,
#   libraries, and archives (.jar files) for the Java Virtual Machine (JVM).
#
# - FPATH / FNDIR: Used by shells like Zsh and KornShell to locate
#   autoloadable shell functions.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#  Zsh shell.

# ----------------------------------------------------------------------------
# Code
# ----
#
#

. "${USRHOME_DIR}/ibin/xtra/sanitize-path-core.sh" || return 1

_usrhome_sanitize_path_validate() {
    # Args: $1 : name of the environment variable

    # Load the zsh/parameter module which provides an associative array
    # containing information about shell parameters.  Stop on loading failure.
    zmodload zsh/parameter || return 1

    # Check that environment variable identified by first argument exists
    # in the associative array. Return 1 if not.
    [[ ${+parameters[$1]} -eq 1 ]] || return 1

    # Check the variable type and attributes.
    case "${parameters[$1]}" in
        # Reject read-only variables.
        *-readonly*)
            return 1
            ;;
        # Accept all scalar and scalar-export variables such
        # as FOOPATH and others.
        scalar|scalar-export)
            return 0
            ;;

        # Accept PATH, MANPATH, CDPATH and FPATH
        scalar-*)
            # Allow the special tied path parameters.
            case "$1" in
                PATH|MANPATH|CDPATH|FPATH) return 0 ;;
            esac
            ;;
    esac

    # Reject any other.
    return 1
}

_usrhome_sanitize_path_read() {
    # Print the value of the variable identified by name by the script's arg 1.
    printf '%s' "${(P)1}"
}

# ----------------------------------------------------------------------------
# Local Variables:
# sh-shell: zsh
# End:
