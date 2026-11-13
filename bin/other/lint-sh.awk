# AWK FILE: lint-sh.awk
#
# Purpose   : Lint shell scripts for lack of -- separators.
# Created   : Friday, November 13 2026.
# Author    : Pierre Rouleau <prouleau001@gmail.com>
# Time-stamp: <2026-11-13 15:45:43 EST, updated by Pierre Rouleau>
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
    printf "%s:%d: [%s] %s\n", fname, NR, message, $0
    found = 1
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
    }
    word = ""
    dyn = udyn = 0
    active = 0
}

function add_dynamic() {
    if (!dyn) dyn = length(word) + 1
}

function audit_segment(    i,j,k,cmd,w,d,stopped,need,pattern,fmt,
                           c,argopt,rest,seg,has_cdpath) {
    i = 1
    while (i <= nt && words[i] ~ /^(if|elif|while|until|then|do|else|!)$/)
        i++
    has_cdpath = 0
    while (i <= nt && words[i] ~ /^[a-zA-Z_][a-zA-Z0-9_]*=/) {
        if (words[i] ~ /^CDPATH=/) has_cdpath = 1
        i++
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

    stopped = need = pattern = 0
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
                    warn("UNSUPPORTED OPTION on " cmd)
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
        if (!stopped && d == 1)
            warn("MISSING -- on " cmd)
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
        if ($0 ~ /"\$[a-zA-Z_][a-zA-Z0-9_]*\//)
            warn("EMPTY VAR RISK - could expand to /sub")
        if ($0 !~ /(\|\||&&|^[[:space:]]*(if|elif|while|until|!)[[:space:]]+cd)/)
            warn("UNCHECKED EXIT on cd")
    }
}

# Heredoc bodies are skipped in the order in which they were declared.
hd_head <= hd_tail {
    text = $0
    if (hd_tabs[hd_head]) sub(/^\t+/, "", text)
    if (text == hd_delim[hd_head]) hd_head++
    next
}

{
    nt = 0
    word = ""
    dyn = udyn = active = redir = here = here_tabs = 0
    quote = ""
    unsupported = 0
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
                warn("UNSUPPORTED line continuation")
                unsupported = 1
                break
            }

            active = 1
            word = word nextc
            p++
            continue
        }

        if (c == dq) {
            active = 1
            quote = (quote == dq ? "" : dq)
            continue
        }
        if (quote == "" && c == sq) {
            active = 1
            quote = sq
            continue
        }
        if (c == "$" && nextc == "(") {
            warn("UNSUPPORTED command substitution")
            unsupported = 1
            break
        }
        if (c == "`") {
            warn("UNSUPPORTED command substitution")
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
            emit_word()
            if (redir) {
                warn("UNSUPPORTED redirection")
                unsupported = 1
                break
            }

            redir = 1
            if (c == "<" && nextc == "<") {
                if (substr($0, p + 2, 1) == "<") {
                    warn("UNSUPPORTED here-string")
                    unsupported = 1
                    break
                }
                here = 1
                p++
                if (substr($0, p + 1, 1) == "-") {
                    here_tabs = 1
                    p++
                }
            } else if (nextc == c || nextc == "&" || nextc == "|") {
                p++
            }

            continue
        }
        if (c ~ /[;&|()]/) {
            emit_word()
            if (redir) {
                warn("UNSUPPORTED redirection")
                unsupported = 1
                break
            }
            audit_segment()
            nt = 0
            continue
        }
        active = 1
        word = word c
    }
    if (quote != "") {
        warn("UNSUPPORTED multiline quote")
        unsupported = 1
    }
    if (!unsupported) {
        emit_word()
        if (redir) warn("UNSUPPORTED redirection")
        else audit_segment()
    }
}

END {
    if (hd_head <= hd_tail) {
        printf "%s:%d: [UNTERMINATED heredoc]\n", fname, NR
        found = 1
    }
    exit found
}

# ------------------------------------------------------------------------------
