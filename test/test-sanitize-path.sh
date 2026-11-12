#!/bin/sh
#
# Purpose   : est ibin/xtra/sanitize-path-posix.sh.
# Created   : Sunday, November 08 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-11 10:22:48 EST, updated by Pierre Rouleau>
# ----------------------------------------------------------------------------
#
# Run from the repository root with the shell to test.
#
# Optional argument: path to the sanitizer file.

if [ "$#" -gt 1 ]; then
    printf '%s\n' 'Usage: test-sanitize-path.sh [sanitizer-file]' >&2
    exit 2
fi

_test_file=${1-./ibin/xtra/sanitize-path-posix.sh}
case $_test_file in
    */*) ;;
    *) _test_file="./$_test_file" ;;
esac

if [ ! -f "$_test_file" ] || [ ! -r "$_test_file" ]; then
    printf 'Cannot read sanitizer: %s\n' "$_test_file" >&2
    exit 2
fi

# Make whitespace classification and warning behavior predictable.
LC_ALL=C
SHELL_IS_INTERACTIVE=false
export LC_ALL SHELL_IS_INTERACTIVE

if ! . "$_test_file"; then
    printf 'Cannot load sanitizer: %s\n' "$_test_file" >&2
    exit 2
fi

_test_passed=0
_test_failed=0
_test_skipped=0

# Each case runs in a subshell. This isolates PATH and the other variables.
#
# Arguments:
#   label, variable, input, expected value, expected status, call mode
# The call mode is "default" or "named".
run_case() {
    if (
        case $2 in
            PATH)   PATH=$3 ;;
            MANPATH) MANPATH=$3 ;;
            CPATH)  CPATH=$3 ;;
            CDPATH) CDPATH=$3 ;;
            FPATH)  FPATH=$3 ;;
            *)
                printf 'Unknown test variable: %s\n' "$2" >&2
                exit 1
                ;;
        esac

        if [ "$6" = default ]; then
            if _usrhome_sanitize_path; then
                _test_status=0
            else
                _test_status=$?
            fi
        else
            if _usrhome_sanitize_path "$2"; then
                _test_status=0
            else
                _test_status=$?
            fi
        fi

        case $2 in
            PATH)    _test_actual=$PATH ;;
            MANPATH) _test_actual=$MANPATH ;;
            CPATH)   _test_actual=$CPATH ;;
            CDPATH)  _test_actual=$CDPATH ;;
            FPATH)   _test_actual=$FPATH ;;
        esac

        if [ "$_test_status" -ne "$5" ] || [ "$_test_actual" != "$4" ]; then
            printf '  status: expected %s, got %s\n' "$5" "$_test_status" >&2
            printf '  value:  expected [%s], got [%s]\n' "$4" "$_test_actual" >&2
            exit 1
        fi

        # A successful result must not change on a second call.
        if [ "$_test_status" -eq 0 ]; then
            if _usrhome_sanitize_path "$2"; then
                :
            else
                printf '%s\n' '  second call failed' >&2
                exit 1
            fi

            case $2 in
                PATH)    _test_actual=$PATH ;;
                MANPATH) _test_actual=$MANPATH ;;
                CPATH)   _test_actual=$CPATH ;;
                CDPATH)  _test_actual=$CDPATH ;;
                FPATH)   _test_actual=$FPATH ;;
            esac

            if [ "$_test_actual" != "$4" ]; then
                printf '  second value: expected [%s], got [%s]\n' \
                    "$4" "$_test_actual" >&2
                exit 1
            fi
        fi
    ); then
        printf 'PASS: %s\n' "$1"
        _test_passed=$((_test_passed + 1))
    else
        printf 'FAIL: %s\n' "$1" >&2
        _test_failed=$((_test_failed + 1))
    fi
}

# Check invalid requests. The test expects status 1 and no change to CPATH
# or PATH. The readonly and unset cases also check their target variables.
run_rejection() {
    if (
        CPATH=/untouched
        _test_original_path=$PATH
        _test_kind=$1

        case $_test_kind in
            unset)
                unset USRHOME_TEST_MISSING
                set -- USRHOME_TEST_MISSING
                ;;
            readonly)
                readonly USRHOME_TEST_READONLY='/a::/b'
                set -- USRHOME_TEST_READONLY
                ;;
            empty-name) set -- '' ;;
            digit-name) set -- '1BAD' ;;
            invalid-name) set -- 'BAD-NAME' ;;
            too-many) set -- CPATH MANPATH ;;
            *)
                printf 'Unknown rejection case: %s\n' "$_test_kind" >&2
                exit 1
                ;;
        esac

        if _usrhome_sanitize_path "$@"; then
            _test_status=0
        else
            _test_status=$?
        fi

        if [ "$_test_status" -ne 1 ] ||
           [ "$CPATH" != /untouched ] ||
           [ "$PATH" != "$_test_original_path" ]; then
            printf '  expected status 1 and unchanged variables; got status %s\n' \
                "$_test_status" >&2
            exit 1
        fi

        case $_test_kind in
            unset)
                if [ "${USRHOME_TEST_MISSING+x}" = x ]; then
                    printf '%s\n' '  unset variable was created' >&2
                    exit 1
                fi
                ;;
            readonly)
                if [ "$USRHOME_TEST_READONLY" != '/a::/b' ]; then
                    printf '%s\n' '  readonly variable changed' >&2
                    exit 1
                fi
                ;;
        esac
    ); then
        printf 'PASS: reject %s\n' "$1"
        _test_passed=$((_test_passed + 1))
    else
        printf 'FAIL: reject %s\n' "$1" >&2
        _test_failed=$((_test_failed + 1))
    fi
}

# Ordinary path-like variables.
run_case 'default PATH' PATH ':/abc:: /def:/abc:' '/abc:/def' 0 default
run_case 'named PATH' PATH '/abc:/abc:/def' '/abc:/def' 0 named
run_case 'CPATH empty fields' CPATH ':/abc::/def:' '/abc:/def' 0 named
run_case 'trim before deduplication' CPATH '/abc:  /abc:/def' '/abc:/def' 0 named
run_case 'exact duplicate comparison' CPATH '/abc:/abcd:/abc' '/abc:/abcd' 0 named
run_case 'preserve trailing space' CPATH '/abc :/abc' '/abc :/abc' 0 named
run_case 'CDPATH' CDPATH ':/abc::/def:/abc' '/abc:/def' 0 named
run_case 'FPATH' FPATH ':/abc::/def:/abc' '/abc:/def' 0 named

# MANPATH: a single colon or one original marker is allowed.
run_case 'MANPATH single colon' MANPATH ':' ':' 0 named
run_case 'MANPATH unchanged' MANPATH '/abc:/def' '/abc:/def' 0 named
run_case 'MANPATH leading marker' MANPATH ':/abc' ':/abc' 0 named
run_case 'MANPATH trailing marker' MANPATH '/abc:' '/abc:' 0 named
run_case 'MANPATH internal marker' MANPATH '/abc::/def' '/abc::/def' 0 named
run_case 'MANPATH marker and trim' MANPATH '/abc::  /def' '/abc::/def' 0 named
run_case 'MANPATH leading marker and trim' MANPATH ':/abc:  /def' ':/abc:/def' 0 named
run_case 'MANPATH marker and later trim' MANPATH '/abc::/def:  /ghi' '/abc::/def:/ghi' 0 named

# Multiple markers, long colon runs, or whitespace-only fields invalidate
# every marker. Normal separators remain between retained directories.
run_case 'MANPATH both ends' MANPATH ':/abc:' '/abc' 0 named
run_case 'MANPATH leading and internal' MANPATH ':/abc::/def' '/abc:/def' 0 named
run_case 'MANPATH two internal markers' MANPATH '/abc::/def::/ghi' '/abc:/def:/ghi' 0 named
run_case 'MANPATH three markers' MANPATH ':/abc::/def:' '/abc:/def' 0 named
run_case 'MANPATH long internal run' MANPATH '/abc:::/def' '/abc:/def' 0 named
run_case 'MANPATH long leading run' MANPATH '::/abc' '/abc' 0 named
run_case 'MANPATH long trailing run' MANPATH '/abc::' '/abc' 0 named
run_case 'MANPATH whitespace-only field' MANPATH '/abc:   :/def' '/abc:/def' 0 named
run_case 'MANPATH duplicate after marker' MANPATH '/abc::/abc' '/abc' 0 named

# An empty result returns 2 and leaves the original value unchanged.
run_case 'empty PATH' PATH '' '' 2 named
run_case 'single colon PATH' PATH ':' ':' 2 named
run_case 'single colon CPATH' CPATH ':' ':' 2 named
run_case 'empty CPATH result' CPATH '::' '::' 2 named
run_case 'empty MANPATH result' MANPATH '::' '::' 2 named
run_case 'MANPATH whitespace and colon' MANPATH ' :' ' :' 2 named
run_case 'whitespace-only result' CPATH '   :  ' '   :  ' 2 named

run_rejection unset
run_rejection readonly
run_rejection empty-name
run_rejection digit-name
run_rejection invalid-name
run_rejection too-many

# Use a child shell to check that a previously unexported CPATH is exported.
_test_child=$(command -v sh 2>/dev/null) || _test_child=
case $_test_child in
    /*)
        if (
            unset CPATH
            CPATH='/abc::/def'
            if ! _usrhome_sanitize_path CPATH; then
                exit 1
            fi
            "$_test_child" -c '[ "${CPATH-}" = "/abc:/def" ]'
        ); then
            printf '%s\n' 'PASS: export CPATH'
            _test_passed=$((_test_passed + 1))
        else
            printf '%s\n' 'FAIL: export CPATH' >&2
            _test_failed=$((_test_failed + 1))
        fi
        if (
            unset MANPATH
            MANPATH=':'
            if ! _usrhome_sanitize_path MANPATH; then
                exit 1
            fi
            "$_test_child" -c '[ "${MANPATH-}" = ":" ]'
        ); then
            printf '%s\n' 'PASS: export single-colon MANPATH'
            _test_passed=$((_test_passed + 1))
        else
            printf '%s\n' 'FAIL: export single-colon MANPATH' >&2
            _test_failed=$((_test_failed + 1))
        fi
        ;;
    *)
        printf '%s\n' 'SKIP: export CPATH; no absolute sh executable found'
        _test_skipped=$((_test_skipped + 1))
        printf '%s\n' 'SKIP: export single-colon MANPATH; no absolute sh executable found'
        _test_skipped=$((_test_skipped + 1))
        ;;
esac

printf '\nPassed: %s; failed: %s; skipped: %s\n' \
    "$_test_passed" "$_test_failed" "$_test_skipped"

if [ "$_test_failed" -ne 0 ]; then
    exit 1
fi
exit 0

# ----------------------------------------------------------------------------
#  Local Variables:
#  sh-shell: sh
#  End:
