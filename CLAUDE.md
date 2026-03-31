# Piwigo Repository Workflow & Standards

## 📋 Overview

This document defines the development workflow, branch strategy, and standards for managing Piwigo core with custom patches for specific releases.

### Problem Context
- **Upstream Piwigo** has two streams:
  - `master` = latest development (unpublished)
  - `tags` (e.g., 16.3.0) = official stable releases
- **Our patches** target stable releases, not `master`, because:
  - Master evolves unpredictably
  - Patches on releases are reproducible and maintainable
  - New patches must adapt when new releases are published

---

## 🌿 Branch Strategy

### Three Types of Branches

| Branch | Base | Purpose | Status |
|--------|------|---------|--------|
| `master` | upstream | Follow Piwigo development | Always in sync with `upstream/master` |
| `feature/XXXX-*` | `master` | Develop new features or fixes | Candidate for PR to Piwigo upstream |
| `patches/X.Y.Z` | tag `X.Y.Z` | Stable release + patches | **Production-ready patches only** |

### Key Rules for Release Branches (`patches/X.Y.Z`)

⚠️ **CRITICAL**: Original Piwigo files on release branches MUST remain **bit-for-bit identical** to the official tag.

- **DO**: Add only new patches and adaptations in `local/patches/`
- **DO NOT**: Modify core Piwigo files on `patches/X.Y.Z`
- **WHY**: Patches must cleanly apply to unmodified release code, ensuring full functionality

---

## 🔄 Workflow

### Starting a New Feature

```bash
# 1. Update master from upstream
git checkout master
git pull origin master

# 2. Create feature branch
git checkout -b feature/2534-menubar-hook
# Name pattern: feature/ISSUE-NUMBER-short-description
```

### Developing the Feature

```bash
# 3. Make changes on the feature branch
# Commit frequently with clear messages
git add .
git commit -m "Fix: add menubar hook for plugin management"

# 4. Test thoroughly on master context
npm test  # or your test suite
```

### Creating the Patch (Without Waiting for Upstream)

Once the feature is complete and tested:

```bash
# 5. Switch to release branch (e.g., 16.3.0)
git checkout patches/16.3.0

# 6. Check that release files are still pristine
git diff master -- admin/ include/ language/ themes/default/
# Result: should show ONLY local/patches/ differences

# 7. Cherry-pick or adapt feature commits for the release version
# Option A: cherry-pick (if it applies cleanly)
git cherry-pick <commit-hash>

# Option B: manual adaptation (if conflicts exist)
# - Apply changes conceptually
# - Test compatibility with release
# - Ensure all edits work on release code

# 8. Commit the adapted work
git add .
git commit -m "Adapt #2534 menubar hook for Piwigo 16.3.0"

# 9. Generate the patch file
git format-patch tags/16.3.0 -o local/patches/ -1
# Creates: local/patches/0001-Adapt-2534-menubar-hook-for-Piwigo-16.3.0.patch

# 10. Test the patch applies cleanly
patch --dry-run -R < local/patches/0001-Adapt-2534-menubar-hook-for-Piwigo-16.3.0.patch

# 11. Commit the patch file
git add local/patches/
git commit -m "Patch #2534: add menubar hook for Piwigo 16.3.0"
```

### Proposing to Upstream (Optional)

```bash
# If you want to propose the feature to Piwigo:
git checkout feature/2534-menubar-hook
git push origin feature/2534-menubar-hook
# Create PR on Piwigo/Piwigo toward master

# NOTE: Don't wait for Piwigo's response.
# Your patch on patches/16.3.0 is already functional and independent.
```

---

## 📦 Release Patch Format

Patch files go in `local/patches/` with this naming convention:

```
ISSUE-SHORT-DESCRIPTION.patch
ISSUE-SHORT-DESCRIPTION_variant.patch  (if multiple versions exist)
ISSUE-SHORT-DESCRIPTION_tested.patch    (if a tested variant is available)
```

Example:
```
local/patches/
  ├── 2534-admin-menubar-hook.patch           # Primary patch
  ├── 2534-admin-menubar-hook_tested.patch    # Fully tested variant
  ├── 2533-sharpening-parameter.patch         # Another issue
  └── README.md                               # Patch documentation
```

Each patch must:
- ✅ Apply cleanly to its target release tag
- ✅ Be tested before committing
- ✅ Have a clear description in `README.md`
- ✅ Be independent (no dependencies on other patches unless documented)

---

## 🔄 Upgrading to a New Release

When Piwigo releases v16.4.0:

```bash
# 1. Fetch new releases
git fetch origin

# 2. Create new release branch
git checkout tags/16.4.0
git checkout -b patches/16.4.0

# 3. Test if old patches still apply
for patch in local/patches/*.patch; do
  patch --dry-run -p1 < "$patch" || echo "CONFLICT: $patch"
done

# 4. Adapt patches for new release
# For each patch that doesn't apply:
#   - Cherry-pick from feature/ branch, adapt for 16.4.0
#   - Test thoroughly
#   - Regenerate patch file

# 5. Commit and test
git add local/patches/
git commit -m "Adapt patches for Piwigo 16.4.0"
```

Old release branches are kept as archives (e.g., `patches/16.3.0`, `patches/16.2.0`).

---

## ✅ Quality Standards

### Commits
- Clear, descriptive commit messages
- One logical change per commit
- Reference issue numbers: `Fix #2534: description`

### Patches
- Always test with `patch --dry-run` before committing
- Include context (test results, compatibility notes)
- Document in `local/patches/README.md`

### Code Review
- Feature branches should be review-ready before creating patches
- Patches inherit the quality standards of the feature they came from

---

## 📝 File Integrity on Release Branches

The `.gitignore` explicitly tracks `local/patches/*`:

```gitignore
/local/*
!/local/**/index.php
!/local/patches/*  ← Patches are tracked
```

This ensures:
- ✅ Patches are version-controlled
- ✅ Only `local/patches/` changes on release branches
- ✅ All core Piwigo files remain pristine from the tag

---

## 🚀 Quick Reference

| Task | Command |
|------|---------|
| Create feature branch | `git checkout -b feature/XXXX-description` |
| Switch to release patches | `git checkout patches/16.3.0` |
| Verify release integrity | `git diff master -- admin/ include/ language/` |
| Generate patch | `git format-patch tags/16.3.0 -o local/patches/` |
| Test patch applies | `patch --dry-run -p1 < file.patch` |
| Upgrade release | `git checkout tags/16.4.0 && git checkout -b patches/16.4.0` |

---

## 💡 Tips

- **Before cherry-picking**: Check that feature commits touch only app logic, not release infrastructure
- **Conflict resolution**: Manually adapt code to the release version, don't merge branches directly
- **Testing patches**: Apply to a clean 16.3.0 checkout to verify isolation
- **Staying organized**: Keep `feature/` branches short-lived; merge into `patches/X.Y.Z` quickly

---

Last updated: 2026-03-31
