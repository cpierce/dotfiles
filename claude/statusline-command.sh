#!/bin/bash
# StatusLine command, single left-aligned line:
#   <cwd> | <Model> | <5h%> | <wk%> | <ctx%>
# Percentages are 5-hour usage, 7-day usage, and context-window used.
# Absent metrics (free plan, before first API response) are dropped cleanly.

# Multibyte glyphs (✳) must count as 1 char for padding math.
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')

# Git branch for the cwd. --no-optional-locks avoids contending with
# concurrent git commands; stderr is dropped so a non-repo dir just yields "".
branch=""
changes=0
ahead=""
behind=""
if [ -n "$dir" ] && [ -d "$dir" ]; then
    branch=$(git -C "$dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    if [ -z "$branch" ]; then
        # Detached HEAD (or no commits yet): fall back to a short SHA.
        branch=$(git -C "$dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    fi
    if [ -n "$branch" ]; then
        # Working-tree churn: one combined count of dirty + untracked entries.
        # -unormal keeps an untracked dir as a single entry so huge fresh
        # dirs stay cheap.
        changes=$(git -C "$dir" --no-optional-locks status --porcelain -unormal 2>/dev/null | grep -c .)
        # Commits ahead/behind upstream; both empty when no upstream is set.
        read -r behind ahead <<< "$(git -C "$dir" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)"
    fi
fi
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
thinking_on=$(echo "$input" | jq -r '.thinking.enabled // false')
effort=$(echo "$input" | jq -r '.effort.level // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
# Per-model weekly bucket (the "Current week (Fable)" bar in /usage) is not
# sent to statusline scripts today — read likely future field names defensively
# so it lights up automatically if Claude Code ever adds it.
model_week=$(echo "$input" | jq -r '.rate_limits.seven_day_fable.used_percentage // .rate_limits.seven_day_opus.used_percentage // .rate_limits.seven_day_model.used_percentage // empty')

# Until then, fetch it from the same OAuth usage endpoint /usage uses.
# The fetch runs in the BACKGROUND and writes a cache file; rendering always
# reads the cache, so the status line never blocks on the network. The OAuth
# token is read from the Keychain (macOS) or ~/.claude/.credentials.json
# (Linux) at fetch time and never written anywhere else.
USAGE_CACHE="$HOME/.claude/statusline-usage-cache.json"
CACHE_TTL=120

cache_age=99999
if [ -f "$USAGE_CACHE" ]; then
    now=$(date +%s)
    # BSD stat (macOS) first, GNU stat (Linux) second.
    mtime=$(stat -f %m "$USAGE_CACHE" 2>/dev/null || stat -c %Y "$USAGE_CACHE" 2>/dev/null || echo 0)
    cache_age=$(( now - mtime ))
fi
if [ "$cache_age" -gt "$CACHE_TTL" ]; then
    (
        # macOS keeps the OAuth blob in Keychain; Linux keeps it in a file.
        token=$({ security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null \
                  || cat "$HOME/.claude/.credentials.json" 2>/dev/null; } \
            | jq -r '.claudeAiOauth.accessToken // empty')
        if [ -n "$token" ]; then
            out=$(curl -sS -m 5 "https://api.anthropic.com/api/oauth/usage" \
                -H "Authorization: Bearer $token" \
                -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)
            if [ -n "$out" ] && printf '%s' "$out" | jq -e '.limits' >/dev/null 2>&1; then
                printf '%s' "$out" > "$USAGE_CACHE"
            fi
        fi
    ) >/dev/null 2>&1 &
fi

if [ -z "$model_week" ] && [ -f "$USAGE_CACHE" ]; then
    model_week=$(jq -r '[.limits[] | select(.kind == "weekly_scoped") | .percent] | first // empty' "$USAGE_CACHE" 2>/dev/null)
fi

# Abbreviate $HOME to ~
if [ -n "$dir" ]; then
    dir="${dir/#$HOME/~}"
fi

ESC=$'\033'
RESET="${ESC}[0m"
DIM="${ESC}[2m"
MODEL_COLOR="${ESC}[38;5;111m"
DIR_COLOR="${ESC}[38;5;114m"
BRANCH_COLOR="${ESC}[38;5;143m"

# Heat-map a usage percentage: green ramps through yellow/amber/orange to
# hot red as it approaches 100.
pct_color() {
    if [ "$1" -ge 95 ]; then
        echo "196"   # red
    elif [ "$1" -ge 85 ]; then
        echo "202"   # red-orange
    elif [ "$1" -ge 70 ]; then
        echo "208"   # orange
    elif [ "$1" -ge 55 ]; then
        echo "214"   # amber
    elif [ "$1" -ge 40 ]; then
        echo "178"   # yellow
    elif [ "$1" -ge 20 ]; then
        echo "149"   # yellow-green
    else
        echo "114"   # green
    fi
}

# Mini equalizer gauge for effort level: filled cells lit, rest dim.
# low ▂____  medium ▂▄___  high ▂▄▆__  xhigh ▂▄▆█_  max all lit
effort_gauge() {
    local lvl=0
    case "$1" in
        low) lvl=1 ;;
        medium) lvl=2 ;;
        high) lvl=3 ;;
        xhigh) lvl=4 ;;
        max) lvl=5 ;;
        *) return ;;
    esac
    local cells=(▁ ▂ ▄ ▆ █) out="" i
    for i in 0 1 2 3 4; do
        if [ "$i" -lt "$lvl" ]; then
            out="${out}${ESC}[38;5;141m${cells[$i]}${RESET}"
        else
            out="${out}${DIM}${cells[$i]}${RESET}"
        fi
    done
    printf '%s' "$out"
}

# Humanize a token count: 353001 -> 353k, 1000000 -> 1M
fmt_tokens() {
    awk -v n="$1" 'BEGIN{
        if (n >= 1000000) { v = n / 1000000; printf (v == int(v)) ? "%dM" : "%.1fM", v }
        else if (n >= 1000) { printf "%dk", int(n / 1000 + 0.5) }
        else { printf "%d", n }
    }'
}

# LEFT: current working dir [+ git branch [●changes ↑ahead ↓behind]]
branch_part=""
if [ -n "$branch" ]; then
    state=""
    if [ "$changes" -gt 0 ]; then
        state=" ${BRANCH_COLOR}●${changes}${RESET}"
    fi
    if [ -n "$ahead" ] && [ "$ahead" -gt 0 ]; then
        state="${state} ${BRANCH_COLOR}↑${ahead}${RESET}"
    fi
    if [ -n "$behind" ] && [ "$behind" -gt 0 ]; then
        state="${state} ${ESC}[38;5;167m↓${behind}${RESET}"
    fi
    branch_part=" ${DIM}(${RESET}${BRANCH_COLOR}${branch}${RESET}${state}${DIM})${RESET}"
fi

left=""
if [ -n "$dir" ]; then
    left="${DIR_COLOR}${dir}${RESET}${branch_part}"
fi

# RIGHT line 1: [✳ if thinking] Model (ctx% context · tokens) | $cost
pre=""
if [ "$thinking_on" = "true" ]; then
    pre="${ESC}[38;5;141m✳${RESET}"
fi

model_seg="${pre}${pre:+ }${MODEL_COLOR}${model}${RESET}"
if [ -n "$ctx" ]; then
    ctx_pct=$(printf '%.0f' "$ctx")
    ctx_color=$(pct_color "$ctx_pct")
    tok_part=""
    if [ -n "$ctx_tokens" ] && [ -n "$ctx_size" ]; then
        tok_part="${DIM} · $(fmt_tokens "$ctx_tokens")/$(fmt_tokens "$ctx_size")${RESET}"
    fi
    model_seg="${model_seg} ${DIM}(${RESET}${ESC}[38;5;${ctx_color}m${ctx_pct}%${RESET}${DIM} context${RESET}${tok_part}${DIM})${RESET}"
fi

sep=" ${DIM}|${RESET} "
right="$model_seg"
if [ -n "$cost" ]; then
    right="${right}${sep}$(printf '$%.2f' "$cost")"
fi

# RIGHT line 2: [+added -removed] | 5h% | wk% | fable-wk%
usage_line=""
if [ -n "$effort" ]; then
    gauge=$(effort_gauge "$effort")
    [ -n "$gauge" ] && usage_line="$gauge"
fi
diff_seg=""
if [ -n "$lines_added" ] && [ "$lines_added" != "0" ]; then
    diff_seg="${ESC}[38;5;114m+${lines_added}${RESET}"
fi
if [ -n "$lines_removed" ] && [ "$lines_removed" != "0" ]; then
    diff_seg="${diff_seg}${diff_seg:+ }${ESC}[38;5;167m-${lines_removed}${RESET}"
fi
if [ -n "$diff_seg" ]; then
    usage_line="${usage_line}${usage_line:+$sep}${diff_seg}"
fi
usage_vals=("$five_hour" "$seven_day" "$model_week")
usage_labels=("s" "w" "f")
for i in 0 1 2; do
    raw="${usage_vals[$i]}"
    if [ -n "$raw" ]; then
        pct=$(printf '%.0f' "$raw")
        color=$(pct_color "$pct")
        [ -n "$usage_line" ] && usage_line="${usage_line}${sep}"
        usage_line="${usage_line}${ESC}[38;5;${color}m${pct}%${RESET} ${DIM}${usage_labels[$i]}${RESET}"
    fi
done

# Session duration (wall clock), dim; hidden under a minute.
if [ -n "$duration_ms" ]; then
    dur_secs=$(( ${duration_ms%.*} / 1000 ))
    if [ "$dur_secs" -ge 60 ]; then
        dur_mins=$(( dur_secs / 60 ))
        if [ "$dur_mins" -ge 60 ]; then
            dur="$(( dur_mins / 60 ))h $(( dur_mins % 60 ))m"
        else
            dur="${dur_mins}m"
        fi
        usage_line="${usage_line}${usage_line:+$sep}${DIM}${dur}${RESET}"
    fi
fi

# Visible length (ANSI escapes stripped)
visible_len() {
    local stripped
    stripped=$(printf '%s' "$1" | sed -E "s/${ESC}\[[0-9;]*m//g")
    printf '%s' "${#stripped}"
}

cols="${COLUMNS:-$(tput cols 2>/dev/null)}"
cols="${cols:-120}"
# Claude Code indents the status row and shares it with other UI, so don't
# pad to the full terminal width — leave a margin or the line wraps/truncates.
cols=$(( cols - 6 ))

right_len=$(visible_len "$right")
padding=$(( cols - $(visible_len "$left") - right_len ))

# Too narrow for the full path? Retry with just the directory basename.
if [ -n "$left" ] && [ "$padding" -lt 1 ]; then
    short="${dir##*/}"
    left="${DIR_COLOR}${short}${RESET}${branch_part}"
    padding=$(( cols - $(visible_len "$left") - right_len ))
fi

if [ -z "$left" ] || [ "$padding" -lt 1 ]; then
    # Still doesn't fit (or no dir at all): usage numbers win.
    printf '%s' "$right"
else
    printf '%s%*s%s' "$left" "$padding" "" "$right"
fi

# Second line: the three usage percentages, flush against the right edge.
# Lead with a RESET so the padding can't be treated as trimmable whitespace.
if [ -n "$usage_line" ]; then
    pad2=$(( cols - $(visible_len "$usage_line") ))
    printf '\n'
    if [ "$pad2" -ge 1 ]; then
        printf '%s%*s%s' "$RESET" "$pad2" "" "$usage_line"
    else
        printf '%s' "$usage_line"
    fi
fi
