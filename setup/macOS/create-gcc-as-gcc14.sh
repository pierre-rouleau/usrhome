#!/bin/sh
# SH FILE: create-gcc-as-gcc14.sh
#
# Purpose   : Build the ~/bin/gcc-14 directory with symlinks to homebrew gcc.
# Created   : Saturday, May 25 2024.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2024-05-28 17:27:03 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
# Creates the $HOME/bin/gcc-14 to hold the symbolic links to the Homebrew
# installed GCC 14 toolchain binaries.  The script supports Apple Silicon
# macOS system where Homebrew installs the files inside the /opt/homebrew
# directory tree.
#
# After installing the file it creates a $HOME/bin/gcc symbolic link to the
# $HOME/bin/gcc-14 so that when support for GCC is requested its GCC 14 that
# is provided.

# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
# Expects that GCC has previously been installed by Homebrew and this is a
# macOS Apple Silicon based system.  The script currently does not support the
# older Homebrew file system organization that is used in Intel Apple macOS
# systems.

# ----------------------------------------------------------------------------
# Code
# ----
#
#
case "$(uname)" in
    Darwin)
        case "$(arch)" in
            arm64)
                echo "Checking macOS arm64 Homebrew requirements..."
                if [ ! -d /opt/homebrew/Cellar/gcc/14.1.0/bin ]; then
                    printf -- "*** ERROR : Homebrew gcc 14 is not installed.\n"
                    printf -- "    Please first install it with: brew install gcc@14\n"
                    printf -- "*******************************************\n"
                    exit 1
                fi
                ;;

            i386)
                echo "Checking macOS i386 Homebrew requirements..."
                if [ ! -h /usr/local/bin/gcc-11 ]; then
                    printf -- "*** ERROR : Homebrew gcc 11 is not installed.\n"
                    printf -- "    Please first install it with: brew install gcc@14\n"
                    printf -- "*******************************************\n"
                    exit 1
                fi
                ;;

            *)
                printf -- "*** ERROR : unsupported architecture: %s\n" "$(arch)"
                printf -- "*******************************************\n"
                exit 1
                ;;
        esac
        ;;
    *)
        printf -- "*** ERROR : This script only support macOS.\n"
        printf -- "            It does not support %s\n" "$(uname)"
        printf -- "*******************************************\n"
        exit 1
        ;;
esac

if [ -d "$HOME/bin/gcc-14" ]; then
    printf -- "*** ERROR : The $HOME/bin/gcc-14 directory already exists.\n"
    printf -- "    As this already been installed?\n"
    printf -- "    To proceed rename or delete that gcc directory.\n"
    printf -- "*******************************************\n"
    exit 1
fi



mkdir "$HOME/bin/gcc-14"          || exit 1

if [ "$(arch)" = "arm64" ]; then
    # Create the symlinks for Apple Silicon Homebrew-installed executable files

    cd    "$HOME/bin/gcc-14"          || exit 1

    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/c++-14        c++          || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/cpp-14        cpp          || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/g++-14        g++          || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcc-14        gcc          || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcc-ar-14     ar           || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcc-nm-14     nm           || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcc-ranlib-14 ranlib       || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcov-14       gcov         || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcov-dump-14  gcov-dump    || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gcov-tool-14  gcov-tool    || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/gfortran-14   gfortran     || exit 1
    ln -s  /opt/homebrew/Cellar/gcc/14.1.0/bin/lto-dump-14   lto-dump     || exit 1

    # Also install links to architecture specific directory
    # In case this is needed.  These appear to be the exact same files
    mkdir "$HOME/bin/aarch64-gcc-14"  || exit 1
    cd    "$HOME/bin/aarch64-gcc-14"  || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-c++-14        c++         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-g++-14        g++         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-gcc-14        gcc         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-gcc-ar-14     ar          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-gcc-nm-14     nm          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-gcc-ranlib-14 ranlib      || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/bin/aarch64-apple-darwin23-gfortran-14   gfortran-14 || exit 1

    # Now create directory that contains symlinks to the gcc-14 man files.
    # Name all symlinks without the -14 prefix, so it becomes possible to request
    # man help for gcc instead of having to request it for gcc-14.

    mkdir "$HOME/bin/gcc-14/man"          || exit 1
    mkdir "$HOME/bin/gcc-14/man/man1"     || exit 1
    mkdir "$HOME/bin/gcc-14/man/man7"     || exit 1

    # And create the symlinks
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/cpp-14.1         "$HOME/bin/gcc-14/man/man1/cpp.1"       || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/g++-14.1         "$HOME/bin/gcc-14/man/man1/g++.1"       || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/gcc-14.1         "$HOME/bin/gcc-14/man/man1/gcc.1"       || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/gcov-14.1        "$HOME/bin/gcc-14/man/man1/gcov.1"      || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/gcov-dump-14.1   "$HOME/bin/gcc-14/man/man1/gcov-dump.1" || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/gcov-tool-14.1   "$HOME/bin/gcc-14/man/man1/gcov-tool.1" || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/gfortran-14.1    "$HOME/bin/gcc-14/man/man1/gfortran.1"  || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man1/lto-dump-14.1    "$HOME/bin/gcc-14/man/man1/lto-dump.1"  || exit 1

    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man7/fsf-funding-14.7 "$HOME/bin/gcc-14/man/man7/fsf-funding.7" || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man7/gfdl-14.7        "$HOME/bin/gcc-14/man/man7/gfdl.7"        || exit 1
    ln -s /opt/homebrew/Cellar/gcc/14.1.0/share/man/man7/gpl-14.7         "$HOME/bin/gcc-14/man/man7/gpl.7"         || exit 1

    # Set the C++ Include path
    # Ref: https://gcc.gnu.org/onlinedocs/cpp/Environment-Variables.html
    CPLUS_INCLUDE_PATH="/opt/homebrew/Cellar/gcc/14.1.0/include/c++/14:$CPLUS_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH

else
    # Create the symlinks for the Apple i386 (x86_64) Homebrew installed executable files
    cd    "$HOME/bin/gcc-14"                       || exit 1
    ln -s /usr/local/bin/c++-14         c++        || exit 1
    ln -s /usr/local/bin/cpp-14         cpp        || exit 1
    ln -s /usr/local/bin/g++-14         g++        || exit 1
    ln -s /usr/local/bin/gcc-14         gcc        || exit 1
    ln -s /usr/local/bin/gcc-ar-14      ar         || exit 1
    ln -s /usr/local/bin/gcc-nm-14      nm         || exit 1
    ln -s /usr/local/bin/gcc-ranlib-14  ranlib     || exit 1
    ln -s /usr/local/bin/gcov-14        gcov       || exit 1
    ln -s /usr/local/bin/gcov-dump-14   gcov-dump  || exit 1
    ln -s /usr/local/bin/gcov-tool-14   gcov-tool  || exit 1
    ln -s /usr/local/bin/gfortran-14    gfortran   || exit 1
    ln -s /usr/local/bin/lto-dump-14    lto-dump   || exit 1

    # Create the symlinks for the man files
    mkdir "$HOME/bin/gcc-14/man"                   || exit 1
    mkdir "$HOME/bin/gcc-14/man/man1"              || exit 1
    mkdir "$HOME/bin/gcc-14/man/man7"              || exit 1

    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/cpp-14.1         "$HOME/bin/gcc-14/man/man1/cpp.1"       || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/g++-14.1         "$HOME/bin/gcc-14/man/man1/g++.1"       || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/gcc-14.1         "$HOME/bin/gcc-14/man/man1/gcc.1"       || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/gcov-14.1        "$HOME/bin/gcc-14/man/man1/gcov.1"      || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/gcov-dump-14.1   "$HOME/bin/gcc-14/man/man1/gcov-dump.1" || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/gcov-tool-14.1   "$HOME/bin/gcc-14/man/man1/gcov-tool.1" || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/gfortran-14.1    "$HOME/bin/gcc-14/man/man1/gfortran.1"  || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man1/lto-dump-14.1    "$HOME/bin/gcc-14/man/man1/lto-dump.1"  || exit 1

    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man7/fsf-funding-14.7 "$HOME/bin/gcc-14/man/man7/fsf-funding.7" || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man7/gfdl-14.7        "$HOME/bin/gcc-14/man/man7/gfdl.7"        || exit 1
    ln -s /usr/local/Cellar/gcc/14.1.0/share/man/man7/gpl-14.7         "$HOME/bin/gcc-14/man/man7/gpl.7"         || exit 1

    # Set the C++ Include path
    # Ref: https://gcc.gnu.org/onlinedocs/cpp/Environment-Variables.html
    CPLUS_INCLUDE_PATH="/usr/local/Cellar/gcc/14.1.0/include/c++/14:$CPLUS_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH
fi

echo "Installation complete.  You can now issue the use-gcc14 command."

# ----------------------------------------------------------------------------
