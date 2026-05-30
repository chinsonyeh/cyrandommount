# WoW Addon GitHub Release Skill

---
name: wow-addon-github-release
description: >
  Automates the full GitHub release workflow for a World of Warcraft addon (CYRandomMount pattern).
  Use when the user says "release version X", "進版 vX.Y.Z", "發版", or wants to tag and push
  a new addon release. Handles version bumping in .toc, ReleaseNotes.md update, git commit,
  tag creation (with v-prefix), and push to trigger GitHub Actions CI/CD.
---

## Overview

This skill automates the complete release workflow for the CYRandomMount WoW addon project.
The GitHub Actions workflow (`release.yml`) is triggered by a `v*` tag push and handles
CurseForge upload automatically.

## Workflow Steps

### Step 1 — Gather Information

Ask the user for the new version number if not already provided.
Example: "請問新版本號是什麼？例如 v2.7.3"

Determine the `NEW_VERSION` (e.g. `2.7.3`) and `NEW_TAG` (e.g. `v2.7.3`).

Check current versions by reading:
- `CYRandomMount.toc` → `## Version:` line
- `ReleaseNotes.md` → first `## [X.Y.Z]` heading

### Step 2 — Validate Pre-conditions

Run the version check script to verify current state:
```powershell
.\check_version.ps1 -tag vCURRENT_VERSION
```

If this fails, report the inconsistency to the user and stop.

Check for uncommitted changes:
```powershell
git status --short
```

If there are uncommitted staged changes unrelated to the release, warn the user.

### Step 3 — Update ReleaseNotes.md

#### 3a. Discover Changes via `git diff`

Find the previous release tag to compare against:
```powershell
git tag --sort=-creatordate | Select-Object -First 1
```

Run `git diff` between the previous tag and HEAD to understand what changed in the code:
```powershell
git diff PREVIOUS_TAG HEAD -- *.lua *.toc
```

Analyze the diff output carefully to identify:
- **New features or capabilities** → `Added`
- **Modifications to existing behavior** → `Changed`
- **Bug fixes** → `Fixed`
- **Removed functionality** → `Removed`

#### 3b. Write Release Notes per `copilot-releasenote.md` Guidelines

Read the project's release note guidelines at `.github/copilot-releasenote.md` before writing.
Key rules from that document:

- Use standard **Keep a Changelog** categories: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`
- **Start each item with an action verb** (e.g. "Added", "Fixed", "Updated", "Improved")
- **Be specific**: mention function names, file names, option names, or module names
- **Mark breaking changes** with `[BREAKING]` tag
- Only include sections that have actual content — omit empty categories
- Versions ordered **newest first** (latest at top)

#### 3c. Confirm with the User

Present the drafted release notes to the user for confirmation before writing to the file:
> "以下是根據 git diff 分析出的 Release Notes 草稿，請確認是否正確或需要修改："

After user confirms (or provides edits), prepend a new entry to `ReleaseNotes.md` in this exact format:
```markdown
## [X.Y.Z]
### Added
- (specific, action-verb-led description)

### Changed
- (specific, action-verb-led description)

### Fixed
- (specific, action-verb-led description)
```

Insert this block **at the top**, right after the file header (after the `# Release Notes` heading and its description paragraph), before any existing `## [X.Y.Z]` entries.

If the user says they have already updated `ReleaseNotes.md` manually, skip to Step 4.

### Step 4 — Update CYRandomMount.toc

In `CYRandomMount.toc`, update the `## Version:` line to the new version number:
```
## Version: X.Y.Z
```

### Step 5 — Verify Versions Match

Run:
```powershell
.\check_version.ps1 -tag vX.Y.Z
```

If this fails, report the error and do NOT proceed with git operations.

### Step 6 — Commit Changes

```powershell
git add CYRandomMount.toc ReleaseNotes.md
git commit -m "Release vX.Y.Z"
```

### Step 7 — Create and Push Tag

Create the tag with the `v` prefix (the GitHub Actions workflow triggers on `v*` tags):
```powershell
git tag vX.Y.Z
git push
git push origin vX.Y.Z
```

> **Important**: Always use lowercase `v` prefix. Never use `-D` flag (uppercase); use `-d` to delete tags.

### Step 8 — Confirm Success

After successful push, report to the user:
- ✅ Tag `vX.Y.Z` pushed to GitHub
- ✅ GitHub Actions will now run `release.yml` to:
  - Create a GitHub Release with the latest release notes
  - Upload the addon ZIP to CurseForge

Provide the GitHub Actions link:
```
https://github.com/chinsonyeh/cyrandommount/actions
```

## File Locations (Project Root)

| File | Purpose |
|------|---------|
| `CYRandomMount.toc` | Contains `## Version: X.Y.Z` |
| `ReleaseNotes.md` | Changelog; latest entry extracted by CI |
| `check_version.ps1` | Validates TOC and ReleaseNotes versions match tag |
| `.github/workflows/release.yml` | GitHub Actions; triggers on `v*` tags |

## Version Format Rules

- Semantic Versioning: `MAJOR.MINOR.PATCH` (e.g. `2.7.3`)
- Git tag must have `v` prefix: `v2.7.3`
- `ReleaseNotes.md` entry uses square brackets: `## [2.7.3]`
- `CYRandomMount.toc` uses bare version: `## Version: 2.7.3`

## Error Handling

| Situation | Action |
|-----------|--------|
| `check_version.ps1` fails | Report mismatch, stop, ask user to fix manually |
| Tag already exists locally | Run `git tag -d vX.Y.Z` then recreate |
| Tag already exists remotely | Ask user before running `git push origin :refs/tags/vX.Y.Z` |
| Uncommitted changes | Warn user, but proceed if they confirm |
| Working directory not in project root | Use the CYRandomMount project path |

## Example Interaction

**User:** 幫我進版 v2.7.3，新增了一個修復坐騎清單顯示的功能

**AI should:**
1. Parse version `2.7.3` and tag `v2.7.3`
2. Ask for change details or use the provided description
3. Update `ReleaseNotes.md` with `## [2.7.3]` entry
4. Update `CYRandomMount.toc` `## Version: 2.7.3`
5. Run `check_version.ps1 -tag v2.7.3`
6. `git add CYRandomMount.toc ReleaseNotes.md`
7. `git commit -m "Release v2.7.3"`
8. `git tag v2.7.3`
9. `git push`
10. `git push origin v2.7.3`
11. Report success with GitHub Actions link

## Notes

- The GitHub Actions workflow reads `CYRandomMount.toc` for the `## Interface:` version to determine WoW game version for CurseForge automatically. No need to manually set game version.
- The workflow extracts the **latest** release notes section from `ReleaseNotes.md` (up to the second `## [` heading) for the GitHub Release body.
- Secrets required in GitHub: `CF_API_TOKEN` (CurseForge API token), environment: `CYRandomMount`.
