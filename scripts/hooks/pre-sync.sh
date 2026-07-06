#!/usr/bin/env bash
# ==============================================================
# pre-sync.sh — Pre-sync hook for Content Sync agent
#
# This script runs BEFORE the content sync workflow begins.
# It captures the current state of the live website so it can
# be compared against the post-sync state.
#
# The Content Sync agent uses browser tools to execute these
# checks. This script serves as the authoritative checklist
# and configuration source for the agent.
#
# Usage:
#   This is invoked by the Content Sync agent during Step 0.
#   It can also be sourced for environment variables.
# ==============================================================

set -euo pipefail

# ---- Configuration ----
SITE_URL="${SITE_URL:-https://absent-from-chronic-site.vercel.app}"
SNAPSHOT_DIR="${SNAPSHOT_DIR:-./.sync-snapshots/pre}"
REPORT_FILE="${SNAPSHOT_DIR}/pre-sync-report.md"

# ---- Pages to snapshot ----
PAGES=(
  "/"
  "/site-map.html"
  "/project/project-proposal.html"
  "/pipeline/pipeline-guide.html"
  "/analysis/exposure.html"
  "/analysis/facilitating.html"
  "/analysis/missingness.html"
  "/analysis/needs.html"
  "/analysis/outcome.html"
  "/analysis/outcome-distribution.html"
  "/analysis/predisposing.html"
)

# ---- Hooks ----
echo "============================================"
echo "  PRE-SYNC HOOK"
echo "============================================"
echo "Site:       ${SITE_URL}"
echo "Snapshot:   ${SNAPSHOT_DIR}"
echo "Report:     ${REPORT_FILE}"
echo "Pages:      ${#PAGES[@]}"
echo ""
echo "The agent should:"

echo ""
echo "  1. Open each page via browser tools"
echo "  2. Take a screenshot of each page"
echo "  3. Check for 404 errors or broken content"
echo "  4. Verify all links on site-map.html resolve"
echo "  5. Store screenshots in ${SNAPSHOT_DIR}/"
echo "  6. Write a pre-sync report to ${REPORT_FILE}"
echo ""

mkdir -p "${SNAPSHOT_DIR}"

cat > "${REPORT_FILE}" <<- REPORT_EOF
# Pre-Sync Website Report
- **Date:** $(date -u "+%Y-%m-%dT%H:%M:%SZ")
- **Site URL:** ${SITE_URL}
- **Pages checked:** ${#PAGES[@]}

## Page Status

| Page | Status | Notes |
|------|--------|-------|
REPORT_EOF

for page in "${PAGES[@]}"; do
  echo "| ${page} | ⏳ pending |  |" >> "${REPORT_FILE}"
done

echo ""
echo "✅ Pre-sync report template created at ${REPORT_FILE}"
echo "ℹ️  Agent: proceed to capture screenshots and fill in the report."
echo "============================================"
