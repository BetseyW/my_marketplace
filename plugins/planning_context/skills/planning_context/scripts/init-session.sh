#!/usr/bin/env bash
# planning-context: initialise planning files for a new session.
#
# Usage:
#   ./init-session.sh                              # legacy: root-level 4 files
#   ./init-session.sh "Backend Refactor"           # slug mode: .context/<date>-backend-refactor/
#   ./init-session.sh --plan-dir                   # slug mode with auto-generated untitled-<short> name
#   ./init-session.sh --plan-dir "Quick Spike"     # slug mode, explicit slug
#   ./init-session.sh --autonomous "Long Run"      # v3 autonomous mode (opt-in)
#   ./init-session.sh --gated "Gated Run"          # v3 gated mode (implies autonomous)
#
# Files created: task_plan.md, findings.md, progress.md, handoff.md
# Templates are read from ${SKILL_ROOT}/templates/*.md; if a template file is
# missing the script falls back to a minimal embedded stub so init still works.
#
# v3 modes (--autonomous / --gated) write a .mode marker next to the plan, reset
# the .stop_blocks gate counter, write a fresh 16-hex nonce for delimiter
# framing, and auto-attest the plan. With no v3 flag and no .mode file, behavior
# stays compatible with legacy plan resolution.

set -e

PROJECT_NAME=""
USE_PLAN_DIR=0
MODE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --plan-dir)
            USE_PLAN_DIR=1
            shift
            ;;
        --autonomous)
            # autonomous wins only if --gated hasn't already been set (gated
            # implies autonomous and is the stronger marker).
            if [ "$MODE" != "gated" ]; then
                MODE="autonomous"
            fi
            shift
            ;;
        --gated)
            MODE="gated"
            shift
            ;;
        *)
            if [ -z "$PROJECT_NAME" ]; then
                PROJECT_NAME="$1"
            else
                PROJECT_NAME="$PROJECT_NAME $1"
            fi
            shift
            ;;
    esac
done

DATE=$(date +%Y-%m-%d)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_ROOT/templates"

# Slug mode triggers when a project name was given OR --plan-dir was passed.
SLUG_MODE=0
if [ -n "$PROJECT_NAME" ] || [ "$USE_PLAN_DIR" -eq 1 ]; then
    SLUG_MODE=1
fi

slugify() {
    # Lowercase, non-alphanumerics → '-', collapse repeats, trim leading/trailing '-'
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[^a-z0-9]/-/g' -e 's/-\{2,\}/-/g' -e 's/^-//' -e 's/-$//' \
        | cut -c1-40
}

short_uuid() {
    # Probe each candidate: command -v alone is not enough on Windows because
    # App Execution Aliases report presence but exit non-zero when run.
    _py="${PYTHON_BIN:-}"
    if [ -z "$_py" ]; then
        for _c in python3 python py; do
            if command -v "$_c" >/dev/null 2>&1 && "$_c" -c "import uuid" >/dev/null 2>&1; then
                _py="$_c"
                break
            fi
        done
    fi
    if [ -n "$_py" ]; then
        "$_py" -c "import uuid; print(uuid.uuid4().hex[:8])"
        return
    fi
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | tr '[:upper:]' '[:lower:]' | tr -d '-' | cut -c1-8
        return
    fi
    # Last-ditch: seconds timestamp as 8 hex chars.
    printf '%08x' "$(date +%s)" | cut -c1-8
}

gen_nonce() {
    # 16 hex chars for the plan-data delimiter framing. Two short_uuid draws
    # concatenated; when both fall back to the epoch (same second) mix in $$
    # to keep 64 bits of unpredictability.
    _n1="$(short_uuid)"
    _n2="$(short_uuid)"
    if [ "$_n1" = "$_n2" ]; then
        printf '%08x%08x' "$(date +%s)" "$$" | tr -d '\n' | cut -c1-16
    else
        printf '%s%s' "$_n1" "$_n2" | tr -d '\n' | cut -c1-16
    fi
}

# Minimal fallback stubs — only used when the template file is missing.
fallback_task_plan() {
    cat > "$1" << 'EOF'
# Task Plan

## Overall Goal
**Current** — [YYYY-MM-DD initial]
[One-paragraph end-state description]

## Phases

### Phase 1: [phase goal]
- **Status:** in_progress

#### Pending
- [ ] [item]
EOF
}

fallback_findings() {
    cat > "$1" << 'EOF'
# Findings & Decisions

## Sessions Index

## Task Inputs

### Requirements

### User Constraints & Preferences

## Findings by Category

### 1. Research
### 2. Decisions
### 3. Issues
### 4. Dead Ends
### 5. Resources
### 6. Multimodal
EOF
}

fallback_progress() {
    cat > "$1" << EOF
# Progress Log

## Session ${DATE} - [summary]

- **Status:** in_progress
- **Log:**
  -
- **Handoff:**
  - Did:
  - Next:
EOF
}

fallback_handoff() {
    cat > "$1" << EOF
# Handoff

## Snapshot
- **Date:** ${DATE}
- **Overall goal:** [copy from task_plan.md]
- **Current objective:** [one sentence]
- **Current phase:** Phase 1
- **Status:** in_progress
- **Branch:** [branch name or unknown]
- **Working tree:** [clean | dirty | unknown]

## Next Best Step
1.
2.
3.
EOF
}

# Copy a template file into the target if it exists; otherwise run the fallback
# writer. Prints "Created <path>" or "already exists, skipping".
place_file() {
    _target="$1"
    _template="$2"
    _fallback_fn="$3"
    if [ -f "$_target" ]; then
        echo "$_target already exists, skipping"
        return 0
    fi
    if [ -f "$_template" ]; then
        cp "$_template" "$_target"
    else
        "$_fallback_fn" "$_target"
    fi
    echo "Created $_target"
}

create_files_in() {
    _dir="$1"
    place_file "$_dir/task_plan.md" "$TEMPLATE_DIR/task_plan.md" fallback_task_plan
    place_file "$_dir/findings.md"  "$TEMPLATE_DIR/findings.md"  fallback_findings
    place_file "$_dir/progress.md"  "$TEMPLATE_DIR/progress.md"  fallback_progress
    place_file "$_dir/handoff.md"   "$TEMPLATE_DIR/handoff.md"   fallback_handoff
}

# Apply v3 opt-in mode side effects to a plan directory.
#   $1 = plan dir (absolute or relative); dotfiles live directly inside it.
#   $2 = plan file path (task_plan.md) used for auto-attestation resolution.
# No-op when MODE is empty.
apply_v3_mode() {
    _mode_dir="$1"
    _mode_plan="$2"
    [ -z "$MODE" ] && return 0

    # (a) reset the gate block counter and drop any stale gate ledger so a prior
    #     run's high block count cannot let the next run stop instantly.
    printf '0\n' > "${_mode_dir}/.stop_blocks"
    rm -f "${_mode_dir}/.gate_last_ledger" 2>/dev/null || true

    # (b) write a fresh 16-hex nonce for delimiter framing.
    gen_nonce > "${_mode_dir}/.nonce"

    # (c) mode marker. gated implies autonomous, so it carries both tokens.
    if [ "$MODE" = "gated" ]; then
        printf 'autonomous gate\n' > "${_mode_dir}/.mode"
    else
        printf 'autonomous\n' > "${_mode_dir}/.mode"
    fi

    # (d) auto-attest the plan (attestation default-on in v3 modes).
    _attest="${SCRIPT_DIR}/attest-plan.sh"
    if [ -f "${_attest}" ] && [ -f "${_mode_plan}" ]; then
        PLAN_ID="${PLAN_ID:-}" sh "${_attest}" >/dev/null 2>&1 || true
    fi
}

if [ "$SLUG_MODE" -eq 1 ]; then
    SLUG="$(slugify "$PROJECT_NAME")"
    if [ -z "$SLUG" ]; then
        SLUG="untitled-$(short_uuid)"
    fi
    BASE_ID="${DATE}-${SLUG}"
    PLAN_ID="$BASE_ID"
    PLAN_ROOT="${PWD}/.context"
    counter=2
    while [ -d "${PLAN_ROOT}/${PLAN_ID}" ]; do
        PLAN_ID="${BASE_ID}-${counter}"
        counter=$((counter + 1))
    done
    PLAN_DIR="${PLAN_ROOT}/${PLAN_ID}"
    mkdir -p "$PLAN_DIR"

    echo "Initializing planning files for: ${PROJECT_NAME:-untitled}"
    echo "PLAN_ID=$PLAN_ID"
    create_files_in "$PLAN_DIR"
    printf "%s\n" "$PLAN_ID" > "${PLAN_ROOT}/.active_plan"
    apply_v3_mode "$PLAN_DIR" "${PLAN_DIR}/task_plan.md"
    echo ""
    echo "Active plan recorded: ${PLAN_ROOT}/.active_plan"
    echo "Pin this terminal to the plan for parallel sessions:"
    echo "  export PLAN_ID=$PLAN_ID"
    if [ -n "$MODE" ]; then
        echo "Mode: $(cat "${PLAN_DIR}/.mode") (attested, gate counter reset)"
    fi
else
    PROJECT_NAME="${PROJECT_NAME:-project}"
    echo "Initializing planning files for: $PROJECT_NAME"
    mkdir -p "$(pwd)/.context"
    create_files_in "$(pwd)/.context"
    apply_v3_mode "$(pwd)/.context" "$(pwd)/.context/task_plan.md"
    echo ""
    echo "Planning files initialized!"
    echo "Files: .context/task_plan.md, .context/findings.md, .context/progress.md, .context/handoff.md"
    if [ -n "$MODE" ]; then
        echo "Mode: $(cat "$(pwd)/.context/.mode") (attested, gate counter reset)"
    fi
fi
