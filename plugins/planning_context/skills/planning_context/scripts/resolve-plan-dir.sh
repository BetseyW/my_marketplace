#!/bin/sh
# planning-context: resolve active plan directory.
#
# Resolution order:
#   1. $PLAN_ID env var → ./.context/$PLAN_ID/ if exists  (side-task)
#   2. ./.context/.active_plan content → matching dir if exists  (side-task)
#   3. Otherwise empty stdout (caller falls back to ./.context/, the main-line plan)
#
# Design contract (v1.2.0): main-line lives at .context/ root; side-tasks live at
# .context/<slug>/. When no side-task is explicitly active, we ALWAYS default to
# the main-line. The old "newest slug dir by mtime" fallback was removed because
# it silently switched context on the user; the /clear or resume path should
# return to main-line, not to whichever side-task happened to be touched last.
#
# Always exits 0. Never errors out the agent loop.
#
# Usage:
#   PLAN_DIR="$(sh scripts/resolve-plan-dir.sh)"
#   PLAN_FILE="${PLAN_DIR:-.context}/task_plan.md"

set -u

PLAN_ROOT="${1:-${PWD}/.context}"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"

# Plan-id safe-identifier check. Rejects whitespace, path separators, leading
# dots, and empty strings; accepts the YYYY-MM-DD-<slug> shape from
# init-session.sh as well as legacy hand-created names like "alpha" or
# "feature-foo". The intent is to filter garbage content (e.g. a corrupt
# .active_plan file containing only whitespace or random text) without
# enforcing a date prefix that would break backward compatibility.
SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'

slug_is_valid() {
    case "$1" in
        '') return 1 ;;
    esac
    printf "%s" "$1" | grep -Eq "${SLUG_RE}"
}

# Portable path canonicalizer. realpath first (Linux, modern coreutils),
# then readlink -f (older GNU), then python3/python os.path.realpath. Prints
# the canonical absolute path on success; prints nothing and returns 1 on a
# full miss so the caller can decide what to do. No python spawn on the happy
# path: realpath/readlink cover Linux, WSL, Git-Bash, and modern macOS.
canonicalize() {
    target="$1"
    if command -v realpath >/dev/null 2>&1; then
        out="$(realpath "${target}" 2>/dev/null)" && [ -n "${out}" ] && {
            printf "%s\n" "${out}"; return 0; }
    fi
    if command -v readlink >/dev/null 2>&1; then
        out="$(readlink -f "${target}" 2>/dev/null)" && [ -n "${out}" ] && {
            printf "%s\n" "${out}"; return 0; }
    fi
    if command -v python3 >/dev/null 2>&1; then
        out="$(python3 -c "import os,sys;print(os.path.realpath(sys.argv[1]))" "${target}" 2>/dev/null)" \
            && [ -n "${out}" ] && { printf "%s\n" "${out}"; return 0; }
    fi
    if command -v python >/dev/null 2>&1; then
        out="$(python -c "import os,sys;print(os.path.realpath(sys.argv[1]))" "${target}" 2>/dev/null)" \
            && [ -n "${out}" ] && { printf "%s\n" "${out}"; return 0; }
    fi
    return 1
}

# Containment guard (security A1.3): a resolved plan dir must canonicalize to a
# path under the project root (the CWD the script runs from). A symlink inside
# a valid slug dir pointing at /etc or outside the workspace would otherwise let
# the hooks hash and inject an arbitrary file. On any violation we return 1 so
# the caller treats the candidate as unresolved and falls back safely. If
# canonicalization is unavailable for BOTH paths we fail open (return 0) to keep
# legacy behavior byte-equivalent on minimal shells that lack realpath/readlink
# and python; the SLUG_RE check already blocks traversal in the slug name.
is_within_root() {
    candidate="$1"
    root_real="$(canonicalize "${PWD}")" || root_real=""
    cand_real="$(canonicalize "${candidate}")" || cand_real=""
    if [ -z "${root_real}" ] || [ -z "${cand_real}" ]; then
        return 0
    fi
    case "${cand_real}" in
        "${root_real}"|"${root_real}"/*) return 0 ;;
        *) return 1 ;;
    esac
}

resolve_from_env() {
    plan_id="${PLAN_ID:-}"
    slug_is_valid "${plan_id}" || return 1
    candidate="${PLAN_ROOT}/${plan_id}"
    if [ -d "${candidate}" ] && is_within_root "${candidate}"; then
        printf "%s\n" "${candidate}"
        return 0
    fi
    return 1
}

resolve_from_active_file() {
    [ -f "${ACTIVE_FILE}" ] || return 1
    plan_id="$(tr -d '\r\n[:space:]' < "${ACTIVE_FILE}")"
    slug_is_valid "${plan_id}" || return 1
    candidate="${PLAN_ROOT}/${plan_id}"
    if [ -d "${candidate}" ] && is_within_root "${candidate}"; then
        printf "%s\n" "${candidate}"
        return 0
    fi
    return 1
}

if resolve_from_env; then exit 0; fi
if resolve_from_active_file; then exit 0; fi
# No mtime fallback (v1.2.0): unresolved → empty stdout → caller uses .context/
# main-line. See resolution-order comment at the top of this file.
exit 0
