#!/bin/sh
# planning-context: close a side-task and merge its essentials back into the
# main-line plan (v1.2.0).
#
# Usage:
#   close-plan.sh <slug> --summary "<what the side-task did>" \
#                        --finding "<key conclusion for main-line findings>" \
#                        [--keep]
#
# Contract:
#   * Side-tasks live at .context/<slug>/. Main-line lives at .context/ root.
#   * This script APPENDS two records to main-line files, mirroring the
#     agent-drafted-then-user-confirmed contract in SKILL.md:
#       - .context/progress.md ← "Did" line tagged [from side: <slug>]
#       - .context/findings.md ← "Decisions" line tagged [Session ... from side: <slug>]
#   * It DOES NOT edit .context/handoff.md — that is a snapshot with a
#     specific overwrite template, so we print a reminder instead.
#   * By default the side-task directory is archived to .context/.archived/<slug>/;
#     pass --keep to leave it in place.
#   * If .context/.active_plan points at <slug>, the pointer is cleared so
#     main-line becomes active again.
#
# Idempotency: the script does NOT dedupe. If you run it twice with the same
# args you get two entries. Callers should run once per close.

set -e

SLUG=""
SUMMARY=""
FINDING=""
KEEP=0

while [ $# -gt 0 ]; do
    case "$1" in
        --summary)
            [ $# -ge 2 ] || { echo "Error: --summary requires a value" >&2; exit 2; }
            SUMMARY="$2"; shift 2 ;;
        --summary=*)
            SUMMARY="${1#--summary=}"; shift ;;
        --finding)
            [ $# -ge 2 ] || { echo "Error: --finding requires a value" >&2; exit 2; }
            FINDING="$2"; shift 2 ;;
        --finding=*)
            FINDING="${1#--finding=}"; shift ;;
        --keep)
            KEEP=1; shift ;;
        -h|--help)
            sed -n '1,30p' "$0"; exit 0 ;;
        --*)
            echo "Error: unknown flag: $1" >&2; exit 2 ;;
        *)
            if [ -z "$SLUG" ]; then
                SLUG="$1"
            else
                echo "Error: unexpected positional arg: $1" >&2; exit 2
            fi
            shift ;;
    esac
done

if [ -z "$SLUG" ]; then
    echo "Error: side-task slug required." >&2
    echo "Usage: close-plan.sh <slug> --summary '...' --finding '...' [--keep]" >&2
    exit 2
fi

# Slugs must be flat (no path separators) — mirrors set-active-plan.sh guard.
case "$SLUG" in
    */*|*\\*|.|..|"")
        echo "Error: invalid slug: $SLUG" >&2; exit 2 ;;
esac

if [ -z "$SUMMARY" ] || [ -z "$FINDING" ]; then
    echo "Error: both --summary and --finding are required." >&2
    echo "The agent must draft both and confirm with the user before invoking." >&2
    exit 2
fi

PLAN_ROOT="${PWD}/.context"
SIDE_DIR="${PLAN_ROOT}/${SLUG}"
MAIN_PROGRESS="${PLAN_ROOT}/progress.md"
MAIN_FINDINGS="${PLAN_ROOT}/findings.md"
MAIN_HANDOFF="${PLAN_ROOT}/handoff.md"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"

if [ ! -d "$SIDE_DIR" ]; then
    echo "Error: side-task directory not found: $SIDE_DIR" >&2
    echo "Available side-tasks:" >&2
    for d in "$PLAN_ROOT"/*/; do
        [ -d "$d" ] || continue
        n=$(basename "${d%/}")
        case "$n" in .*) continue ;; esac
        echo "  $n" >&2
    done
    exit 1
fi

if [ ! -d "$PLAN_ROOT" ] || [ ! -f "$MAIN_PROGRESS" ]; then
    echo "Error: main-line plan not found (.context/progress.md missing)." >&2
    echo "close-plan.sh merges side-task results back into main-line and requires main-line to exist." >&2
    exit 1
fi

DATE=$(date +%Y-%m-%d)

# Append to main-line progress.md as a distinct block. We deliberately do NOT
# splice into an existing session — the merge is its own event and belongs on
# its own line so the timeline reads honestly.
{
    echo ""
    echo "## Side-task closure: ${SLUG} — ${DATE}"
    echo ""
    echo "- **From side:** ${SLUG}"
    echo "- **Did:** ${SUMMARY}"
    echo "- **Next:** (see main-line task_plan.md — side-task closed, main continues)"
} >> "$MAIN_PROGRESS"

# Append to main-line findings.md. We append at end of file rather than
# splicing into "### 2. Decisions" to avoid brittle in-place mutation of a
# structured markdown file; the [from side: <slug>] tag makes provenance clear.
{
    echo ""
    echo "## Side-task closure: ${SLUG}"
    echo ""
    echo "- [Session ${DATE} from side: ${SLUG}] ${FINDING}"
} >> "$MAIN_FINDINGS"

# Clear the active pointer if it points at this side-task, so main-line
# becomes active on the next hook fire.
if [ -f "$ACTIVE_FILE" ]; then
    _ap="$(tr -d '\r\n[:space:]' < "$ACTIVE_FILE" 2>/dev/null)"
    if [ "$_ap" = "$SLUG" ]; then
        rm -f "$ACTIVE_FILE"
        echo "Cleared .context/.active_plan (was pointing at closed side-task)."
    fi
fi

# Archive the side-task directory (default) or keep it in place.
if [ "$KEEP" -eq 1 ]; then
    echo "Side-task directory left in place: ${SIDE_DIR}"
else
    ARCHIVE_ROOT="${PLAN_ROOT}/.archived"
    mkdir -p "$ARCHIVE_ROOT"
    TARGET="${ARCHIVE_ROOT}/${SLUG}"
    counter=2
    while [ -e "$TARGET" ]; do
        TARGET="${ARCHIVE_ROOT}/${SLUG}-${counter}"
        counter=$((counter + 1))
    done
    mv "$SIDE_DIR" "$TARGET"
    echo "Archived side-task: ${SIDE_DIR} → ${TARGET}"
fi

echo ""
echo "Merged into main-line:"
echo "  ${MAIN_PROGRESS}  ← Did entry"
echo "  ${MAIN_FINDINGS}  ← Key finding"
echo ""
if [ -f "$MAIN_HANDOFF" ]; then
    echo "Reminder: main-line handoff.md was NOT auto-edited. Refresh its"
    echo "\"Active Side-Tasks\" section manually to mark ${SLUG} as closed."
fi
