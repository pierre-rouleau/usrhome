#!/bin/sh
# SH FILE: create-gcc-as-gcc15.sh
#
# Purpose   : Build the ~/bin/gcc-15 directory with symlinks to Homebrew gcc 15.
# Created   : Wednesday, August 27 2025.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2025-08-27 15:26:34 EDT, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#

# The script creates the $HOME/bin/gcc-15 to hold the symbolic links to the
# Homebrew installed GCC 15 tool-chain binaries.

# Note that the script only supports Apple Silicon macOS system where Homebrew
# installs the files inside the /opt/homebrew directory tree, it does not
# support the older macOS Intel architecture.
#
# After installing the file it creates a $HOME/bin/gcc symbolic link to the
# $HOME/bin/gcc-15 so that when support for GCC is requested its GCC 15 that
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
                if [ ! -d /opt/homebrew/Cellar/gcc/15.1.0/bin ]; then
                    printf -- "*** ERROR : Homebrew gcc 15.1 is not installed.\n"
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

if [ -d "$HOME/bin/gcc-15" ]; then
    printf -- "*** ERROR : The $HOME/bin/gcc-15 directory already exists.\n"
    printf -- "    As this already been installed?\n"
    printf -- "    To proceed rename or delete that gcc directory.\n"
    printf -- "*******************************************\n"
    exit 1
fi



mkdir "$HOME/bin/gcc-15"          || exit 1

if [ "$(arch)" = "arm64" ]; then
    # Create the symlinks for Apple Silicon Homebrew-installed executable files

    cd    "$HOME/bin/gcc-15"          || exit 1

    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcc-ar-15     ar            || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/c++-15        c++           || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcc-15        cc            || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/cpp-15        cpp           || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/g++-15        g++           || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcc-15        gcc           || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcov-15       gcov          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcov-dump-15  gcov-dump     || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcov-tool-15  gcov-tool     || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/lto-dump-15   lto-dump      || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcc-nm-15     nm            || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gcc-ranlib-15 ranlib        || exit 1
    # fortran compiler
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gfortran-15   gfortran      || exit 1
    # modula 2 compiler
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/gm2           gm2           || exit 1

    # Now create directory that contains symlinks to the gcc-15 man files.
    # Name all symlinks without the -14 prefix, so it becomes possible to request
    # man help for gcc instead of having to request it for gcc-15.

    mkdir "$HOME/bin/gcc-15/man"          || exit 1
    mkdir "$HOME/bin/gcc-15/man/man1"     || exit 1
    mkdir "$HOME/bin/gcc-15/man/man7"     || exit 1

    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/cpp-15.1         "$HOME/bin/gcc-15/man/man1/cpp.1"          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/g++-15.1         "$HOME/bin/gcc-15/man/man1/g++.1"          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gcc-15.1         "$HOME/bin/gcc-15/man/man1/gcc.1"          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gcov-15.1        "$HOME/bin/gcc-15/man/man1/gcov.1"         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gcov-dump-15.1   "$HOME/bin/gcc-15/man/man1/gcov-dump.1"    || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gcov-tool-15.1   "$HOME/bin/gcc-15/man/man1/gcov-tool.1"    || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gfortran-15.1    "$HOME/bin/gcc-15/man/man1/gfortran.1"     || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/gm2-15.1         "$HOME/bin/gcc-15/man/man1/gm2.1"          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man1/lto-dump-15.1    "$HOME/bin/gcc-15/man/man1/lto-dump.1"     || exit 1

    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man7/fsf-funding-15.7 "$HOME/bin/gcc-15/man/man7/fsf-funding.7"  || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man7/gfdl-15.7        "$HOME/bin/gcc-15/man/man7/gfdl.7"         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/share/man/man7/gpl-15.7         "$HOME/bin/gcc-15/man/man7/gpl.7"          || exit 1


    # Also install links to architecture specific directory
    # in case they are needed.
    # For this version, looking at the MD5 signature of these files, it appears
    # that the aarch64 version of these executable files have the exact content
    # as their standard name counterpart.
    # Because of that I assume that the tool is looking at its invocation name
    # to determine how it should operate. That's why I create the long name that
    # include the 'aarch64-apple-darwin23' string (which is also a string in the
    # binary dump of the files).
    #
    mkdir "$HOME/bin/aarch64-gcc-15"  || exit 1
    cd    "$HOME/bin/aarch64-gcc-15"  || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-c++-15        aarch64-apple-darwin23-c++         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-g++-15        aarch64-apple-darwin23-g++         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gcc-15        aarch64-apple-darwin23-gcc         || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gcc-15        aarch64-apple-darwin23-cc          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gcc-ar-15     aarch64-apple-darwin23-ar          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gcc-nm-15     aarch64-apple-darwin23-nm          || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gcc-ranlib-15 aarch64-apple-darwin23-ranlib      || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gfortran-15   aarch64-apple-darwin23-gfortran    || exit 1
    ln -s /opt/homebrew/Cellar/gcc/15.1.0/bin/aarch64-apple-darwin23-gm2-15        aarch64-apple-darwin23-gm2         || exit 1

    # Set the C++ Include path
    # Ref: https://gcc.gnu.org/onlinedocs/cpp/Environment-Variables.html
    CPLUS_INCLUDE_PATH="/opt/homebrew/Cellar/gcc/15.1.0/include/c++/15:$CPLUS_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH

else
        printf -- "*** ERROR : This script does not support macOS Intel architecture.\n"
        printf -- "*******************************************\n"
        exit 1
fi

echo "Installation complete."
echo "You can now issue the use-gcc15 command to activate GCC 15 in the shell."

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
