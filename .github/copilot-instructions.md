# Copilot instructions

This is a **publishing repository** modeled on
[RG-FIDES/publish-site-template](https://github.com/RG-FIDES/publish-site-template).

It exists to make one frontend of one reproducible research project publicly available
as a static website. It contains the published bytes and the harness that moves them.
It does not contain analysis code, content sources, private data, or a build step.

## Architecture

```
absent-from-chronic (private inputs, code, content)
  └─ _frontend-1/           render here
       └─ _site/            generated artifact
                │
                │  scripts/sync-site.ps1  (audited, hash-verified transfer)
                ▼
absent-from-chronic-site (this repository)
  └─ _site/                 committed artifact  ──push──▶  Vercel (no build)
```

`site.config.json` records the source project, the frontend, and the publish policy.
Read it before doing anything; it is the single source of truth for this harness.

## Project specifics

| Fact | Value |
| --- | --- |
| Source project | `RG-FIDES/absent-from-chronic` |
| Frontend published here | `_frontend-1` |
| Artifact directory | `_site` |
| Entry point | `_site/index.html` (meta-refresh stub) |
| Landing page | `_site/content/index.html` |
| Host | Vercel, serving `_site` directly with no build step |

`publishing-contract.prompt.md` in the repository root is the **content contract** for the
source project's frontend: it defines which source documents become which pages and how they
are transformed. It governs rendering in the source project, not anything in this repository.
Do not treat it as a workflow for this repo.

## Non-negotiables

1. **The source project is read-only.** Never modify, render into, or clean it.
2. **Never hand-edit anything under `_site/`.** It must match the source byte for byte.
   Defects are fixed in the source project and re-imported.
3. **Never publish** source files, data files, secrets, or caches. The transfer script
   blocks them. If it refuses, investigate the source — do not relax the policy.
4. **Deletions require explicit approval.** "Update the site" is not approval to remove
   pages.
5. **Never commit or push** unless the user explicitly asks.
6. **Never render here.** This repository has no build step by design; the private inputs
   required to render are not present.

## Entry points

`site.config.json` decides which path applies: `initialized: false` means bind first,
`initialized: true` means publish.

| Task | Use |
| --- | --- |
| Bind to a frontend, or switch frontends | `/import-frontend` → `scripts/initialize-site.ps1` |
| Publish an updated render | `/publish-site` → `scripts/sync-site.ps1` |
| Detailed procedure and policy reference | `.github/skills/publish-generated-site/SKILL.md` |
| Source project moved on this machine | Update `source.localPath` in `site.config.json` |

This repository is already initialized against `_frontend-1`, so routine work is
`/publish-site`. Do not re-initialize for a content refresh.

## Conventions

- Scripts are PowerShell 5.1-compatible, dry-run by default, and require `-Apply` to
  make changes. Preserve that shape in any new script.
- Shared script logic lives in `scripts/lib/` as dot-sourced function libraries with
  comment-based help. Scripts perform work; libraries only define functions.
- `templates/` holds files rendered at initialization with `{{TOKEN}}` placeholders.
  Adding a token means adding it to the `$tokens` map in `scripts/initialize-site.ps1`.
- New configuration keys must be added to `site.config.json` explicitly, because
  PowerShell cannot assign properties that do not already exist on the parsed object.

## Legacy files

`netlify.toml` and `scripts/netlify-build.sh` are left over from an earlier model in which
the host rendered the site. Deployment now happens on Vercel from the committed `_site`.
Leave them alone unless the user asks for deployment cleanup.
