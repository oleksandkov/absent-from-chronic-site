---
name: publish-generated-site
description: 'Safely publish or sync a newly rendered Quarto website from an absent-from-chronic _frontend-* directory into this production repository. Use when transferring generated _site updates, refreshing production content, or preparing a routine website release.'
argument-hint: 'Provide the source _frontend-* directory or its _site path'
---

# Publish Generated Site

Synchronize only the generated `_site` output. Do not copy source `content/`, Quarto caches,
private data, or source-repository configuration into this production repository.

## Procedure

1. Resolve the supplied source. If it is a frontend directory, use its `_site` child.
2. Confirm the source repository has no uncommitted generated-output changes that the user did
   not intend to publish. Never modify the source.
3. Check this repository's `git status`. Preserve all pre-existing changes and stop if they make
   the `_site` transfer ambiguous.
4. Run a dry comparison:

   ```powershell
   & ./scripts/sync-site.ps1 -Source '<absolute-source-_site-path>'
   ```

5. Report the counts and paths to be added, changed, and deleted. Treat any deletion as an
   explicit review point; do not infer approval for deletions from a general update request.
6. Apply the transfer after the delta is understood:

   ```powershell
   & ./scripts/sync-site.ps1 -Source '<absolute-source-_site-path>' -Apply
   ```

   Add `-AllowDelete` only after deletions have been explicitly approved.
7. Run `git diff --check`, confirm the production `_site` hashes match the source, and scan
   `git status --short` to ensure no files outside `_site` and this workflow's intentional
   maintenance files changed. Report Quarto-generated trailing whitespace, but preserve byte-for-byte
   source parity instead of editing generated HTML to silence it.
8. Serve `_site` locally and check the root redirect, changed pages, navigation, images, and new
   pages in desktop and mobile viewports when browser tools are available.
9. Summarize the transfer. Never commit or push unless the user explicitly asks.

## Release Boundary

- GitHub Actions deploys `./_site` from `main` to GitHub Pages.
- The production repository may also be connected to Vercel or Netlify, but `_site` remains the
  authoritative artifact for this workflow.
- Never alter deployment configuration as part of a content transfer unless the user requests it.
- Never publish `.R`, `.Rmd`, `.qmd`, database/data files, `data-private`, `_cache`, or `.git`.