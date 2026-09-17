#!/bin/sh
# planning-context: set or display the active plan pointer.
#
# Usage:
#   set-active-plan.sh <plan_id>   — pin .context/.active_plan to a side-task slug
#   set-active-plan.sh main        — clear the pointer (return to main-line)
#   set-active-plan.sh             — print the current active plan (if any)
#
# The active plan is stored in .context/.active_plan and is read by
# resolve-plan-dir.sh when no $PLAN_ID env var is set. An empty / missing
# .active_plan means main-line (.context/) is active. Side-tasks live at
# .context/<slug>/; there is no nesting.

set -e

PLAN_ROOT="${PWD}/.context"
ACTIVE_FILE="${PLAN_ROOT}/.active_plan"

# No args → show current active plan
if [ "${1:-}" = "" ]; then
    if [ -f "${ACTIVE_FILE}" ]; then
        plan_id="$(tr -d '\r\n' < "${ACTIVE_FILE}")"
        if [ -n "${plan_id}" ] && [ -d "${PLAN_ROOT}/${plan_id}" ]; then
            echo "Active plan: ${plan_id} (side-task)"
            echo "Path: ${PLAN_ROOT}/${plan_id}"
        elif [ -n "${plan_id}" ]; then
            echo "Active plan pointer: ${plan_id} (directory not found — stale pointer)"
        else
            echo "Active plan: main-line (${PLAN_ROOT})"
        fi
    else
        echo "Active plan: main-line (${PLAN_ROOT})"
    fi
    exit 0
fi

PLAN_ID="$1"

# "main" / "--main" clears the pointer → main-line becomes active.
case "${PLAN_ID}" in
    main|--main|MAIN)
        if [ -f "${ACTIVE_FILE}" ]; then
            rm -f "${ACTIVE_FILE}"
        fi
        echo "Active plan cleared — main-line (${PLAN_ROOT}) is now active."
        echo ""
        echo "Unset any pinned env var to fully return:"
        echo "  unset PLAN_ID"
        exit 0
        ;;
esac

# Reject any slug containing a path separator to enforce flat side-tasks.
case "${PLAN_ID}" in
    */*|*\\*)
        echo "Error: side-task slugs must be flat — no path separators." >&2
        echo "Nested side-tasks (.context/side-a/side-b/) are not allowed." >&2
        exit 1
        ;;
esac

PLAN_DIR="${PLAN_ROOT}/${PLAN_ID}"

if [ ! -d "${PLAN_DIR}" ]; then
    echo "Error: side-task directory not found: ${PLAN_DIR}" >&2
    echo "Run: init-session.sh \"${PLAN_ID}\" to create it, or check .context/ for available side-tasks." >&2
    exit 1
fi

mkdir -p "${PLAN_ROOT}"
printf "%s\n" "${PLAN_ID}" > "${ACTIVE_FILE}"

echo "Active side-task set to: ${PLAN_ID}"
echo "Path: ${PLAN_DIR}"
echo ""
echo "To pin this terminal session only:"
echo "  export PLAN_ID=${PLAN_ID}"
echo ""
echo "Return to main-line with: set-active-plan.sh main"
