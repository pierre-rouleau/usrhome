#!/bin/sh
# SH FILE: test-bin-find-executable.sh
#
# Purpose   : Test bin/find-executable.
# Created   : Thursday, November 26 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-26 14:10:46 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
# Module Description
# ------------------
#
#


# ----------------------------------------------------------------------------
# Dependencies
# ------------
#
#


# ----------------------------------------------------------------------------
# Code
# ----
#
# • -e (errexit). Exits the script immediately if any command returns a non-zero exit status.
# • -u (nounset). Treats referencing an unset (undefined) variable as an error, printing a
#                 message to stderr and immediately exiting the script.
set -eu

# Run from the repository root, normally through test/run-tests.
USRHOME_DIR=$(pwd -P)
USRHOME_PRINT_ENABLED=1
USRHOME_STDERR_PRINT_TO_PIPE=1
TERM=xterm
LC_ALL=C
export USRHOME_DIR USRHOME_PRINT_ENABLED
export USRHOME_STDERR_PRINT_TO_PIPE TERM LC_ALL

work=$(mktemp -d "${TMPDIR:-/tmp}/usrhome-find-executable.XXXXXX")
trap 'rm -rf "$work"' 0
trap 'exit 1' HUP INT TERM
work=$(CDPATH='' cd -P "$work" && pwd -P)
cd "$work"

fail()
{
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

# Source the command in a subshell so the selected test shell parses it.
# Disable test-harness options that the executable does not set itself.
run_find()
(
    trap - 0 HUP INT TERM
    set +eu
    # shellcheck source=../bin/find-executable
    . "$USRHOME_DIR/bin/find-executable"
)

check()
{
    wanted_status=$1
    shift

    # Use the following old POSIX comptatible workaround for safely passing
    # all script arguments along without breaking when zero arguments are
    # given: ${1+"$@"}
    #
    # It breaks down into two parts:
    # • "$@":     Expands to every positional parameter passed to the script,
    #             keeping each argument safely wrapped in its own quotes so
    #             spaces inside arguments don't get split up.
    # • ${1+...}: A parameter expansion rule that means "if parameter $1 is set
    #             (even if it's empty), substitute what follows the +;
    #             otherwise, substitute nothing."
    #
    # This is used to help support testing a large number of POSIX-compliant shells.
    #
    if run_find ${1+"$@"} > "$work/actual" 2> "$work/error"; then
        actual_status=0
    else
        actual_status=$?
    fi

    if [ "$actual_status" -ne "$wanted_status" ]; then
        printf 'Arguments:' >&2
        for check_arg in ${1+"$@"}; do printf ' <%s>' "$check_arg" >&2; done
        printf '\n%s\n' '--- stderr ---' >&2
        cat "$work/error" >&2
        fail "expected status $wanted_status; got $actual_status"
    fi

    # find does not promise traversal order.
    sort "$work/actual" > "$work/sorted"
    sort "$work/expected" > "$work/expected-sorted"
    if ! cmp -s "$work/expected-sorted" "$work/sorted"; then
        printf 'Arguments:' >&2
        for check_arg in ${1+"$@"}; do printf ' <%s>' "$check_arg" >&2; done
        printf '\n%s\n' '--- expected ---' >&2
        cat "$work/expected-sorted" >&2
        printf '%s\n' '--- actual ---' >&2
        cat "$work/sorted" >&2
        printf '%s\n' '--- stderr ---' >&2
        cat "$work/error" >&2
        fail "unexpected stdout"
    fi

    if [ "$wanted_status" -eq 0 ] || [ "$wanted_status" -eq 1 ]; then
        [ ! -s "$work/error" ] || fail "unexpected stderr"
    fi
}

mkdir -p 'tree/visible dir' tree/.hidden empty default outside
: > 'tree/visible dir/owner'
: > 'tree/visible dir/group'
: > 'tree/visible dir/other'
: > 'tree/visible dir/mixed'
: > 'tree/visible dir/plain'
: > tree/.hidden/run
: > outside/run
: > default/run

chmod 100 'tree/visible dir/owner'
chmod 010 'tree/visible dir/group'
chmod 001 'tree/visible dir/other'
chmod 110 'tree/visible dir/mixed'
chmod 644 'tree/visible dir/plain'
chmod 755 tree/.hidden/run outside/run default/run
ln -s ../outside/run tree/link

visible()
{
    printf '%s\n' \
        'tree/visible dir/owner' \
        'tree/visible dir/group' \
        'tree/visible dir/other' \
        'tree/visible dir/mixed'
}

# Default: exclude hidden directories and symbolic links.
visible > "$work/expected"
check 0 tree

for option in -H --inc-hidden; do
    {
        visible
        printf '%s\n' tree/.hidden/run
    } > "$work/expected"
    check 0 "$option" tree
done

for option in -L --inc-link; do
    {
        visible
        printf '%s\n' tree/link
    } > "$work/expected"
    check 0 "$option" tree
done

{
    visible
    printf '%s\n' tree/.hidden/run tree/link
} > "$work/expected"
check 0 -H -L tree

# Empty tree and a tree with no executable files.
: > "$work/expected"
check 1 empty
: > empty/plain
chmod 644 empty/plain
check 1 empty

# Default ROOT is the current directory.
cd "$work/default"
printf '%s\n' ./run > "$work/expected"
check 0
cd "$work"

# Both help spellings succeed and print usage.
for option in -h --help; do
    run_find "$option" > "$work/actual" 2> "$work/error"
    grep -F 'Usage: find-executable' "$work/actual" >/dev/null
    [ ! -s "$work/error" ] || fail "help wrote stderr"
done

# Invalid command lines.
: > "$work/expected"
check 2 missing
grep -F 'Specified ROOT' "$work/error" >/dev/null
check 2 --unknown
grep -F 'Invalid argument' "$work/error" >/dev/null
check 2 tree extra
grep -F 'Too many arguments' "$work/error" >/dev/null

# Isolated OS-dispatch tests. Use the host tools only for assertions.
mkdir mock
cat > mock/uname <<'SH'
#!/bin/sh
printf '%s\n' "$TEST_OS"
SH
cat > mock/find <<'SH'
#!/bin/sh
printf '%s\n' "$@" > "$FIND_ARGS"
printf '%s\n' mock/executable
SH
chmod 755 mock/uname mock/find

original_path=$PATH
PATH="$work/mock:$PATH"
FIND_ARGS="$work/find-args"
export PATH FIND_ARGS

for TEST_OS in Linux Darwin FreeBSD OpenBSD NetBSD DragonFly; do
    export TEST_OS
    printf '%s\n' mock/executable > "$work/expected"
    check 0 tree
    printf '%s\n' tree '(' -perm -100 -o -perm -010 -o -perm -001 ')' \
        -type f '(' '!' -path '*/.*' ')' > "$work/expected-args"
    cmp -s "$work/expected-args" "$FIND_ARGS" ||
        fail "wrong find arguments for $TEST_OS"

    check 0 -L tree
    printf '%s\n' tree '(' -perm -100 -o -perm -010 -o -perm -001 ')' \
        '(' -type f -o -type l ')' '(' '!' -path '*/.*' ')' > "$work/expected-args"
    cmp -s "$work/expected-args" "$FIND_ARGS" ||
        fail "wrong find arguments for $TEST_OS with -L"

done

TEST_OS=UnsupportedOS
export TEST_OS
: > "$work/expected"
check 3 tree
grep -F 'unsupported OS' "$work/error" >/dev/null

PATH=$original_path
export PATH
printf '%s\n' 'PASS: find-executable tests'

# ----------------------------------------------------------------------------
