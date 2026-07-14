#!/usr/bin/env bash
# ==============================================================
# post-sync.sh — Post-sync hook for Content Sync agent
#
# This script runs AFTER the content sync workflow completes
# and the changes have been deployed to Vercel.
#
# It re-captures the website state and compares it against
# the pre-sync snapshot to verify the deployment was successful.
#
# The Content Sync agent uses browser tools to execute these
# checks. This script serves as the authoritative checklist
# and configuration source for the agent.
#
# Usage:
#   This is invoked by the Content Sync agent during Step 6.
#   It can also be sourced for environment variables.
# ==============================================================

set -euo pipefail

# ---- Configuration ----
SITE_URL="${SITE_URL:-https://absent-from-chronic-site.vercel.app}"
PRE_SNAPSHOT_DIR="${PRE_SNAPSHOT_DIR:-./.sync-snapshots/pre}"
POST_SNAPSHOT_DIR="${POST_SNAPSHOT_DIR:-./.sync-snapshots/post}"
COMPARISON_FILE="${COMPARISON_FILE:-./.sync-snapshots/comparison-report.md}"

# ---- Pages to re-check ----
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
echo "  POST-SYNC HOOK"
echo "============================================"
echo "Site:          ${SITE_URL}"
echo "Pre-snapshot:  ${PRE_SNAPSHOT_DIR}"
echo "Post-snapshot: ${POST_SNAPSHOT_DIR}"
echo "Comparison:    ${COMPARISON_FILE}"
echo "Pages:         ${#PAGES[@]}"
echo ""

echo "The agent should:"

echo ""
echo "  1. Wait for Vercel deployment to finish (~15-20 seconds)"
echo "  2. Open each page via browser tools"
echo "  3. Take a fresh screenshot of each page"
echo "  4. Store screenshots in ${POST_SNAPSHOT_DIR}/"
echo "  5. Compare each post-sync screenshot with its pre-sync counterpart"
echo "  6. Check for:"
echo "     - New pages that didn't exist before"
echo "     - Missing pages (404s that weren't there before)"
echo "     - Layout/content differences"
echo "     - Broken links on site-map.html"
echo "  7. Write a comparison report to ${COMPARISON_FILE}"
echo "  8. Ask the user if they want to sync again or are satisfied"
echo ""

mkdir -p "${POST_SNAPSHOT_DIR}"

cat > "${COMPARISON_FILE}" <<- REPORT_EOF
# Post-Sync Comparison Report
- **Date:** $(date -u "+%Y-%m-%dT%H:%M:%SZ")
- **Site URL:** ${SITE_URL}
- **Pages compared:** ${#PAGES[@]}

## Comparison Results

| Page | Pre-sync | Post-sync | Changed? | Notes |
|------|----------|-----------|----------|-------|
REPORT_EOF

for page in "${PAGES[@]}"; do
  echo "| ${page} | ⏳ pending | ⏳ pending | — |  |" >> "${COMPARISON_FILE}"
done

echo ""
echo "✅ Comparison report template created at ${COMPARISON_FILE}"
echo "ℹ️  Agent: proceed to capture post-sync screenshots and fill in the report."
echo "============================================"
