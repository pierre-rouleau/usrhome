# AWK FILE: lint-sh.awk
#
# Purpose   : Lint shell scripts for lack of -- separators.
# Created   : Friday, November 13 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-13 15:13:53 EST, updated by Pierre Rouleau>
# ------------------------------------------------------------------------------
# Module Description
# ------------------
#
#


# ------------------------------------------------------------------------------
# Dependencies
# ------------
#
#


# ------------------------------------------------------------------------------
# Code
# ----
#
#
BEGIN {
    found = 0
    in_heredoc = 0
    heredoc_delim = ""
    heredoc_strip_tabs = 0
    in_squote = 0
    in_dquote = 0

    # Configure POSIX commands that support "--" (POSIX Guideline 10)
    cmd_list = "cd cp mv rm mkdir rmdir touch chmod chown ln grep cat head tail wc sort cut diff unset readonly export"
    n = split(cmd_list, arr, " ")
    for (i = 1; i <= n; i++) {
        posix_cmds[arr[i]] = 1
    }
}

# Fallback to FILENAME if -v fname="..." was not passed on the command line
fname == "" {
    fname = FILENAME
}

# 1. Handle active heredoc blocks (e.g., cat <<EOF ... EOF)
in_heredoc {
    line = $0
    if (heredoc_strip_tabs) {
        sub(/^\t+/, "", line)
    }
    if (line == heredoc_delim) {
        in_heredoc = 0
        heredoc_delim = ""
        heredoc_strip_tabs = 0
    }
    next
}

# 2. Detect start of heredoc outside quotes (ignoring <<< here-strings)
!in_squote && !in_dquote && /<<-?[[:space:]]*['"]?[a-zA-Z0-9_]+['"]?/ {
    if ($0 !~ /<<</) {
        temp = $0
        sub(/^.*<<-?[[:space:]]*/, "", temp)
        heredoc_strip_tabs = ($0 ~ /<<-/) ? 1 : 0
        match(temp, /^['"]?[a-zA-Z0-9_]+['"]?/)
        delim = substr(temp, RSTART, RLENGTH)
        gsub(/['"]/, "", delim)
        if (delim != "") {
            in_heredoc = 1
            heredoc_delim = delim
        }
    }
}

# 3. Track multi-line single and double quotes character-by-character
{
    was_in_quote = (in_squote || in_dquote)
    len = length($0)
    for (i = 1; i <= len; i++) {
        c = substr($0, i, 1)
        prev = (i > 1) ? substr($0, i - 1, 1) : ""

        if (!in_squote && !in_dquote && c == "#") {
            break
        }

        if (c == "'" && !in_dquote) {
            in_squote = !in_squote
        } else if (c == "\"" && !in_squote && prev != "\\") {
            in_dquote = !in_dquote
        }
    }

    if (was_in_quote || in_squote || in_dquote) {
        next
    }
}

# 4. Skip full-line comments
/^[[:space:]]*#/ { next }

# 5. Sanitize line and evaluate POSIX commands
{
    line = $0
    # Strip inline comments
    sub(/[[:space:]]+#.*$/, "", line)

    # Strip awk/sed regex literals (/pattern/) to avoid false positives
    gsub(/(~|!~|\(|,)[[:space:]]*\/([^\/\\]|\\.)*\//, " REGEX ", line)

    # Strip safe string/path prefixes (/, ./, ../, ~/) so anchored paths pass
    clean = line
    gsub(/(^|[[:space:]"'])(\/|\.\.?\/|~\/)[^[:space:]"';&|)><]*/, " SAFE_PATH ", clean)

    # Split line into command segments on ;, &&, ||, |, (, )
    seg_count = split(clean, segments, /[;&|()]+/)

    for (s = 1; s <= seg_count; s++) {
        seg = segments[s]
        sub(/^[[:space:]]+/, "", seg)
        sub(/[[:space:]]+$/, "", seg)

        # Skip common control keywords prefixing a command
        sub(/^(if|elif|while|until|then|do|else|!)[[:space:]]+/, "", seg)
        # Skip inline variable assignments (e.g., CDPATH="" cd ...)
        while (seg ~ /^[a-zA-Z_][a-zA-Z0-9_]*=[^[:space:]]*[[:space:]]+/) {
            sub(/^[a-zA-Z_][a-zA-Z0-9_]*=[^[:space:]]*[[:space:]]+/, "", seg)
        }

        if (seg == "") continue

        # Extract the command name
        tok_count = split(seg, tokens, /[[:space:]]+/)
        cmd = tokens[1]

        # A. Generalized "--" delimiter check across all configured POSIX commands
        if (cmd in posix_cmds) {
            has_double_dash = 0
            has_risky_operand = 0

            for (t = 2; t <= tok_count; t++) {
                tok = tokens[t]

                # Stop checking once "--" is seen
                if (tok == "--") {
                    has_double_dash = 1
                    break
                }

                # Ignore redirections (e.g., >file, 2>/dev/null, <input)
                if (tok ~ /^[0-9]*[<>]/) continue

                # Ignore SAFE_PATH placeholders and lone "-" (stdin/OLDPWD)
                if (tok == "SAFE_PATH" || tok == "-") continue

                # Ignore option flags (starting with "-")
                if (tok ~ /^-/) continue

                # Any remaining token is a variable, glob, or bare relative name
                has_risky_operand = 1
                break
            }

            if (!has_double_dash && has_risky_operand) {
                printf "%s:%d: [MISSING -- on %s] %s\n", fname, NR, cmd, $0
                found = 1
            }
        }

        # B. Specific checks for "cd"
        if (cmd == "cd") {
            # Check for CDPATH exposure (bare relative word without CDPATH=)
            if (seg ~ /^cd[[:space:]]+((-[LP]|--)[[:space:]]+)*[a-zA-Z0-9_]/ &&
                seg !~ /SAFE_PATH/ &&
                line !~ /CDPATH=/) {
                printf "%s:%d: [CDPATH RISK - bare relative path] %s\n", fname, NR, $0
                found = 1
            }

            # Check for unguarded variable prefix (e.g., "$VAR/sub" without :?)
            if (line ~ /"\$[a-zA-Z_][a-zA-Z0-9_]*\//) {
                printf "%s:%d: [EMPTY VAR RISK - could expand to /sub] %s\n", fname, NR, $0
                found = 1
            }

            # Check for missing error handling (||, &&, or if/while guard)
            if (line !~ /(\|\||&&|^[[:space:]]*(if|elif|while|until|!)[[:space:]]+cd)/) {
                printf "%s:%d: [UNCHECKED EXIT on cd] %s\n", fname, NR, $0
                found = 1
            }
        }
    }
}

END {
    exit found
}

# ------------------------------------------------------------------------------
