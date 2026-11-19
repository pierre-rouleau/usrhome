# AWK FILE: lint-sh.awk
#
# Purpose   : Lint shell scripts for lack of -- separators.
# Created   : Friday, November 13 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-19 17:00:13 EST, updated by Pierre Rouleau>
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
    sq = sprintf("%c", 39)
    dq = sprintf("%c", 34)
    found = 0
    error_count = 0
    unsupported_count = 0
    hd_head = 1
    hd_tail = 0

    # Configure POSIX commands that support "--" (POSIX Guideline 10)
    # Short options with required arguments are listed separately.
    opts["cd"]="LP"
    opts["cp"]="fHiLPRr"
    opts["mv"]="fi"
    opts["rm"]="fiRr"
    opts["mkdir"]="mp"
    opts["rmdir"]="p"
    opts["touch"]="acmrt"
    opts["chmod"]="R"
    opts["chown"]="HLPR"
    opts["ln"]="fs"
    opts["grep"]="EFGcefilnqsvx"
    opts["cat"]="u"
    opts["head"]="n"
    opts["tail"]="fcn"
    opts["wc"]="clmw"
    opts["sort"]="bcdfikmnortu"
    opts["cut"]="bcdfns"
    opts["diff"]="bcefinru"
    opts["unset"]="fv"
    opts["readonly"]="p"
    opts["export"]="p"
    opts["alias"]=""
    opts["set"]="abCefhmnouvx"
    args["mkdir"]="m"
    args["touch"]="rt"
    args["grep"]="ef"
    args["head"]="n"
    args["tail"]="cn"
    args["sort"]="kot"
    args["cut"]="bcdf"
    args["set"]="o"
}

# Fallback to FILENAME if -v fname="..." was not passed on the command line
fname == "" {
    fname = FILENAME
}

function warn(message) {
    warn_at(message, NR, $0)
}

function warn_at(message, line_number, source_line) {
    if (message ~ /^WARNING: UNSUPPORTED([[:space:]]|$)/) {
        unsupported_count++
        # Quiet mode ignores unsupported constructs for the exit status.
        if (hide_unsupported != 2)
            found = 1
        if (hide_unsupported)
            return
    } else {
        error_count++
        found = 1
    }
    printf "%s:%d: [%s] %s\n", fname, line_number, message, source_line
}

# A word is stored without quote characters, but with the position of
# its first expansion. This is a lexer, not a full shell parser.
function emit_word() {
    if (!active) return
    if (redir) {
        if (here) {
            hd_tail++
            hd_delim[hd_tail] = word
            hd_tabs[hd_tail] = here_tabs
        }
        redir = here = here_tabs = 0
    } else {
        nt++
        words[nt] = word
        dynamic[nt] = dyn
        unquoted[nt] = udyn
        word_quoted[nt] = was_quoted
    }
    word = ""
    dyn = udyn = was_quoted = 0
    active = 0
}

function add_dynamic() {
    if (!dyn) dyn = length(word) + 1
}

function audit_segment(end_op, tail,    i,j,k,cmd,w,d,stopped,need,pattern,fmt,
                       c,argopt,rest,seg,has_cdpath,missing_reported,
                       condition_kind,checked) {
    i = 1
    condition_kind = ""
    while (i <= nt && words[i] ~ /^(if|elif|while|until|then|do|else|!)$/) {
        if (words[i] ~ /^(if|elif|while|until)$/)
            condition_kind = words[i]
        i++
    }
    has_cdpath = 0
    while (i <= nt && words[i] ~ /^[a-zA-Z_][a-zA-Z0-9_]*=/) {
        if (words[i] ~ /^CDPATH=/)
            has_cdpath = (words[i] == "CDPATH=" && !dynamic[i])
        i++
    }
    # Unwrap command invocations before auditing the utility.  Options
    # consumed here belong to command, not to the utility.
    while (i <= nt && words[i] == "command" && !dynamic[i]) {
        i++
        while (i <= nt) {
            w = words[i]
            if (dynamic[i]) {
                warn("WARNING: UNSUPPORTED dynamic command wrapper")
                return
            }
            if (w == "--") {
                i++
                break
            }
            if (w !~ /^-/ || w == "-") break
            if (w !~ /^-[pvV]+$/) {
                warn("WARNING: UNSUPPORTED OPTION on command")
                return
            }
            # -v and -V describe commands; they do not execute them.
            if (w ~ /[vV]/) return
            i++
        }
        if (i <= nt && dynamic[i]) {
            warn("WARNING: UNSUPPORTED dynamic command wrapper")
            return
        }
    }
    if (i > nt) return
    cmd = words[i]
    if (cmd != "printf" && !(cmd in opts)) return

    if (cmd == "printf") {
        fmt = i + 1
        if (fmt <= nt && words[fmt] == "--" && !dynamic[fmt])
            return
        if (fmt <= nt && dynamic[fmt] &&
            (dynamic[fmt] == 1 || words[fmt] ~ /^-/ || unquoted[fmt]))
            warn("MISSING -- on printf")
        return
    }

    stopped = need = pattern = missing_reported = 0
    for (j = i + 1; j <= nt; j++) {
        w = words[j]
        d = dynamic[j]
        if (need) {
            if (unquoted[j])
                warn("UNQUOTED OPTION ARGUMENT on " cmd)
            if (cmd == "grep" && need ~ /^[ef]$/) pattern = 1
            need = 0
            continue
        }
        if (!stopped && w == "--" && !d) {
            stopped = 1
            continue
        }
        if (!stopped && unquoted[j])
            warn("UNQUOTED EXPANSION on " cmd)
        if (!stopped && cmd == "set" && w ~ /^\+/) {
            if (d) {
                warn("DYNAMIC OPTION on set")
                continue
            }
            if (w == "+o") need = "o"
            continue
        }
        if (!stopped && w ~ /^-/ && w != "-") {
            # A dynamic suffix is safe only when a known option has
            # already consumed it as an attached option argument.
            argopt = 0
            for (k = 2; k <= length(w); k++) {
                if (d && k >= d) {
                    warn("DYNAMIC OPTION on " cmd)
                    break
                }
                c = substr(w, k, 1)
                if (!index(opts[cmd], c)) {
                    warn("WARNING: UNSUPPORTED OPTION on " cmd)
                    break
                }
                if (index(args[cmd], c)) {
                    argopt = 1
                    rest = substr(w, k + 1)
                    if (cmd == "grep" && c ~ /^[ef]$/) pattern = 1
                    if (rest == "") need = c
                    break
                }
            }
            continue
        }
        if (!stopped && d == 1 && !missing_reported) {
            warn("MISSING -- on " cmd)
            missing_reported = 1
        }
        if (cmd == "grep" && !pattern) pattern = 1
    }

    if (cmd == "cd") {
        seg = "cd"
        for (j = i + 1; j <= nt; j++) {
            w = words[j]
            if (w ~ /^(\/|\.\.?\/|~\/)/) w = "SAFE_PATH"
            seg = seg " " w
        }
        if (seg ~ /^cd[[:space:]]+((-[LP]|--)[[:space:]]+)*[a-zA-Z0-9_]/ &&
            seg !~ /SAFE_PATH/ && !has_cdpath)
            warn("CDPATH RISK - bare relative path")

        if (logical_line ~ /"\$(\{[a-zA-Z_][a-zA-Z0-9_]*\}|[a-zA-Z_][a-zA-Z0-9_]*)\//)
            warn("EMPTY VAR RISK - could expand to /sub")
        # A following && or || tests this command's status.
        checked = (end_op == "&&" || end_op == "||")

        # Recognize simple, same-line control conditions.  A preceding
        # command in the condition is not sufficient to check this cd.
        if (end_op == ";" &&
            ((condition_kind ~ /^(if|elif)$/ &&
              tail ~ /^[[:space:]]*then([[:space:];]|$)/) ||
             (condition_kind ~ /^(while|until)$/ &&
              tail ~ /^[[:space:]]*do([[:space:];]|$)/)))
            checked = 1

        # Defer the decision when the condition can continue on the
        # next line. Blank lines and comments may precede then or do.
        if (!checked && condition_kind != "" &&
            (end_op == "" ||
             (end_op == ";" && tail ~ /^[[:space:]]*(#.*)?$/))) {
            pending_guard = (condition_kind ~ /^(if|elif)$/) ? "then" : "do"
            pending_guard_line = NR
            pending_guard_text = $0
            checked = 1
        }

        if (!checked)
            warn("UNCHECKED EXIT on cd")
    }
}

# Heredoc bodies are skipped in the order in which they were declared.
hd_head <= hd_tail && !pending_quote {
    text = $0
    if (hd_tabs[hd_head]) sub(/^\t+/, "", text)
    if (text == hd_delim[hd_head]) hd_head++
    next
}

{
    # The heredoc rule above has already skipped any heredoc body.
    if (pending_guard != "" && $0 !~ /^[[:space:]]*(#|$)/) {
        if ((pending_guard == "then" &&
             $0 ~ /^[[:space:]]*then([[:space:];&|()]|$)/) ||
            (pending_guard == "do" &&
             $0 ~ /^[[:space:]]*do([[:space:];&|()]|$)/)) {
            pending_guard = ""
        } else {
            warn_at("UNCHECKED EXIT on cd", pending_guard_line, pending_guard_text)
            pending_guard = ""
        }
    }

    if (!pending_quote) {
        nt = 0
        word = ""
        dyn = udyn = was_quoted = active = redir = here = here_tabs = 0
        quote = ""
        logical_line = $0
    } else {
        logical_line = logical_line "\n" $0
    }
    unsupported = 0
    escaped_newline = 0
    len = length($0)
    for (p = 1; p <= len; p++) {
        c = substr($0, p, 1)
        nextc = substr($0, p + 1, 1)

        if (quote == sq) {
            if (c == sq) quote = ""
            else word = word c
            continue
        }

        if (c == "\\" && quote != sq) {
            if (p == len) {
                if (quote == dq) {
                    # In double quotes, backslash-newline is removed.
                    escaped_newline = 1
                } else {
                    warn("WARNING: UNSUPPORTED line continuation")
                    unsupported = 1
                }
                break
            }

            active = 1
            was_quoted = 1
            word = word nextc
            p++
            continue
        }

        if (c == dq) {
            active = 1
            was_quoted = 1
            if (quote == dq)
                quote = ""
            else {
                quote = dq
                quote_line = NR
            }
            continue
        }
        if (quote == "" && c == sq) {
            active = 1
            was_quoted = 1
            quote = sq
            quote_line = NR
            continue
        }
        if ((c == "$" && nextc == "(") || c == "`") {
            warn("WARNING: UNSUPPORTED command substitution; audit stopped")
            audit_stopped = 1
            unsupported = 1
            break
        }
        if (c == "$" && quote == "") udyn = 1
        if (c == "$" || (quote == "" && c ~ /[*?[]/)) add_dynamic()
        if (quote != "") {
            active = 1
            word = word c
            continue
        }
        if (c == "#" && !active) break
        if (c ~ /[[:space:]]/) {
            emit_word()
            continue
        }
        if (c == "<" || c == ">") {
            if (active && !redir && !was_quoted && !dyn &&
                word ~ /^[0-9]+$/) {
                # An adjacent unquoted number is a file descriptor,
                # not a command argument.
                word = ""
                dyn = udyn = was_quoted = active = 0
            } else {
                emit_word()
            }
            if (redir) {
                warn("WARNING: UNSUPPORTED redirection")
                unsupported = 1
                break
            }

            redir = 1
            if (c == "<" && nextc == "<") {
                if (substr($0, p + 2, 1) == "<") {
                    # Here-string: the next word is a redirection operand,
                    # not a heredoc delimiter.
                    p += 2
                } else {
                    here = 1
                    p++
                    if (substr($0, p + 1, 1) == "-") {
                        here_tabs = 1
                        p++
                    }
                }
            } else if ((c == "<" && nextc == ">") ||
                       nextc == c || nextc == "&" || nextc == "|") {
                p++
            }
            continue
        }
        if (c ~ /[;&|()]/) {
            emit_word()
            if (redir) {
                warn("WARNING: UNSUPPORTED redirection")
                unsupported = 1
                break
            }
            end_op = c
            if ((c == "&" || c == "|") && nextc == c) {
                end_op = c c
                p++
            }
            audit_segment(end_op, substr($0, p + 1))
            nt = 0
            continue
        }
        active = 1
        word = word c
    }
    if (unsupported) {
        # Do not treat a quote left open by an early stop as multiline.
        pending_quote = 0
        quote = ""
        if (audit_stopped) exit
        next
    }
    if (quote != "") {
        if (!escaped_newline)
            word = word "\n"
        pending_quote = 1
        next
    }

    pending_quote = 0
    emit_word()
    if (redir) warn("WARNING: UNSUPPORTED redirection")
    else audit_segment("", "")
}

END {
    if (!audit_stopped && pending_guard != "")
        warn_at("WARNING: UNSUPPORTED incomplete conditional guard",
                pending_guard_line, pending_guard_text)

    if (!audit_stopped && pending_quote) {
        printf "%s:%d: [UNTERMINATED quote]\n", fname, quote_line
        error_count++
        found = 1
    }

    if (!audit_stopped && hd_head <= hd_tail) {
        printf "%s:%d: [UNTERMINATED heredoc]\n", fname, NR
        error_count++
        found = 1
    }

    if (hide_unsupported && unsupported_count > 0) {
        # when hide-unsupported is 2, print nothing
        if (hide_unsupported == 1) {
            printf "%s: [WARNING: %d unsupported diagnostics suppressed; audit incomplete]\n",
                fname, unsupported_count
        }
    }
    if ("LINT_SH_STATS_FILE" in ENVIRON) {
        stats_path = ENVIRON["LINT_SH_STATS_FILE"]
        printf "%.0f %.0f\n", error_count, unsupported_count > stats_path
        if (close(stats_path) != 0)
            exit 2
    }
    exit found
}

# ------------------------------------------------------------------------------
