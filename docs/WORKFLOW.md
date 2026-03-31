# Detailed Workflow Guide: Feature to Patch

This guide walks through a complete example: developing feature #2534 (menubar hook) and creating a patch for Piwigo 16.3.0.

---

## 📝 Example Scenario

**Issue**: Add admin menubar hook for plugins (#2534)  
**Target Release**: Piwigo 16.3.0  
**Upstream Status**: Feature works on master, but PR may not be accepted

---

## Step 1️⃣: Prepare Master

```bash
# Ensure master is up-to-date
git checkout master
git pull origin master

# Verify you're on the right branch
git status
# On branch master
# Your branch is up to date with 'origin/master'
```

---

## Step 2️⃣: Create Feature Branch

```bash
# Create a feature branch from master
git checkout -b feature/2534-menubar-hook

# Verify creation
git branch -v
#  feature/2534-menubar-hook 81f8d65a2 fixes GHSA-...
#  master                    81f8d65a2 fixes GHSA-...
```

**Branch naming**: `feature/{ISSUE-NUMBER}-{short-description}`

---

## Step 3️⃣: Develop the Feature

Make your changes and commit regularly:

```bash
# Example: implement menubar hook
git add admin/admin.php admin/include/functions.php
git commit -m "Feature #2534: add admin_menubar_plugin_links hook"

git add admin/plugins_menubar.php
git commit -m "Feature #2534: create plugin menubar admin page"

git add language/en_UK/admin.lang.php language/fr_FR/admin.lang.php
git commit -m "Feature #2534: add English and French translations"

# Verify your commits
git log --oneline -5
# abc1234 Feature #2534: add English and French translations
# def5678 Feature #2534: create plugin menubar admin page
# ghi9012 Feature #2534: add admin_menubar_plugin_links hook
```

---

## Step 4️⃣: Test on Master

Test thoroughly to ensure everything works:

```bash
# Run your test suite
npm test
# or
php tests/run_tests.php

# Manual testing in a development environment
# Verify the feature works as expected
```

---

## Step 5️⃣: Propose to Upstream (Optional)

If you want to try getting the feature merged upstream:

```bash
# Push your feature branch
git push origin feature/2534-menubar-hook

# Create PR on GitHub at https://github.com/Piwigo/Piwigo
# Title: "Feature #2534: add admin menubar plugin hook"
# Description: explain what it does, why it's needed, etc.

# Note: Don't wait for a response. Piwigo maintainers are slow to review.
# Proceed to Step 6 regardless.
```

---

## Step 6️⃣: Switch to Release Branch

Now create the patch for your stable release:

```bash
# Switch to patches/16.3.0
git checkout patches/16.3.0

# Verify you're on the release branch
git status
# On branch patches/16.3.0
# Your branch is up to date with 'origin/patches/16.3.0'

# Verify release files are pristine (no core modifications)
git diff master -- admin/ include/ language/ themes/default/
# Output should show ONLY differences in local/patches/
# If you see other differences, something is wrong!
```

---

## Step 7️⃣: Adapt Feature for Release

### Option A: Cherry-pick (If it applies cleanly)

If your feature commits don't conflict with release code:

```bash
# Get commit hashes from feature branch
git log feature/2534-menubar-hook --oneline
# abc1234 Feature #2534: add English and French translations
# def5678 Feature #2534: create plugin menubar admin page
# ghi9012 Feature #2534: add admin_menubar_plugin_links hook

# Cherry-pick commits (oldest first)
git cherry-pick ghi9012
git cherry-pick def5678
git cherry-pick abc1234

# If there are conflicts, resolve them and continue
# git cherry-pick --continue
```

### Option B: Manual Adaptation (If conflicts exist)

If cherry-pick fails:

```bash
# Abort the cherry-pick
git cherry-pick --abort

# Manually apply changes from feature branch
# Compare files and understand what changed:
git diff master feature/2534-menubar-hook -- admin/admin.php

# Make the changes manually on 16.3.0
# Ensure they work with the release version of each file
# (16.3.0 may have slightly different code structure)

# Commit your work
git add admin/admin.php admin/include/functions.php ...
git commit -m "Adapt #2534 menubar hook for Piwigo 16.3.0"
```

---

## Step 8️⃣: Test on Release

Test that your adapted changes work on the release version:

```bash
# In a clean Piwigo 16.3.0 environment (or commit locally and test):
# 1. Test that admin pages load
# 2. Test that menubar management works
# 3. Test that plugins can register menu items

# Verify no regressions on release code
# (compare behavior to clean 16.3.0)
```

---

## Step 9️⃣: Generate Patch File

Create the `.patch` file for distribution:

```bash
# Generate patch from release tag to current HEAD
git format-patch tags/16.3.0 -o local/patches/

# This creates files like:
# local/patches/0001-Adapt-2534-menubar-hook-for-Piwigo-16.3.0.patch
# local/patches/0002-....patch
# etc.

# Rename if needed for clarity
mv local/patches/0001-*.patch local/patches/2534-admin-menubar-hook.patch
```

**Patch file naming**:
- Primary: `{ISSUE}-{description}.patch`
- Variant: `{ISSUE}-{description}_{variant}.patch`
- Tested: `{ISSUE}-{description}_tested.patch` (rename to primary when tested)
- Archive: `{ISSUE}-{description}.patch.old` (keep old version as reference)

### ⚠️ CRITICAL: Add CPV Header to Patch Files

Every patch file MUST start with a CPV (Compatible Piwigo Version) header:

```bash
# Edit your generated patch file
nano local/patches/2534-admin-menubar-hook.patch

# Add these two lines at the VERY BEGINNING:
# CPV - Compatible Piwigo Version: 16.3.0
# (blank line)

# Rest of patch follows (starting with "diff --git...")
```

**Result format**:
```diff
# CPV - Compatible Piwigo Version: 16.3.0

diff --git a/admin.php b/admin.php
index afa343086..2c6d66fe6 100644
--- a/admin.php
+++ b/admin.php
...
```

**Why CPV is required**:
- ✅ Identifies target Piwigo release immediately
- ✅ Ensures patches are applied to correct versions
- ✅ Essential for patch management and documentation
- ✅ Prevents accidental application to wrong releases
- ✅ Required first line in all patch files

---

## Step 🔟: Test Patch Application

Verify the patch applies cleanly:

```bash
# Dry-run test (doesn't modify files)
patch --dry-run -p1 < local/patches/2534-admin-menubar-hook.patch
# If successful, no output (or "patching file ..." messages)

# If conflicts appear, adjust the patch and regenerate
```

---

## Step 1️⃣1️⃣: Document Patch

Update `local/patches/README.md`:

```markdown
## Patch: #2534 Admin Menubar Hook

**Target**: Piwigo 16.3.0  
**Issue**: https://github.com/Piwigo/Piwigo/issues/2534  
**Status**: Standalone installation (unofficial)

### What it does
- Adds `admin_menubar_plugin_links` hook for dynamic plugin menu entries
- Allows plugins to register links in the admin menubar
- Includes management page for organizing plugin menu items

### Files affected
- admin/admin.php
- admin/include/functions.php
- admin/plugins_menubar.php (new)
- admin/themes/default/template/plugins_menubar.tpl (new)
- language/en_UK/admin.lang.php
- language/fr_FR/admin.lang.php

### How to apply
```bash
cd /path/to/piwigo/16.3.0
patch -p1 < 2534-admin-menubar-hook.patch
```

### Notes
- Requires no database changes
- Backward compatible (plugin menu only appears if plugins register)
- Tested with v16.3.0 release
```

---

## Step 1️⃣2️⃣: Commit Patch Files

```bash
# Stage patch files and documentation
git add local/patches/2534-admin-menubar-hook.patch
git add local/patches/README.md

# Commit
git commit -m "Patch #2534: add menubar hook for Piwigo 16.3.0

- Feature allows plugins to register admin menubar items
- Patch applies cleanly to release code
- Includes full documentation"

# Verify
git log --oneline -3
# abc1234 Patch #2534: add menubar hook for Piwigo 16.3.0
# def5678 Adapt #2534 menubar hook for Piwigo 16.3.0
# [original release commit]
```

---

## Summary

| Step | Action | Branch |
|------|--------|--------|
| 1-5 | Develop & test feature | `feature/2534-menubar-hook` |
| 6-8 | Adapt for release | `patches/16.3.0` |
| 9-12 | Generate & commit patch | `patches/16.3.0` |

**Result**: A clean, working patch that applies to Piwigo 16.3.0 without any reference to upstream `master`.

---

## Upgrading to a New Release

When Piwigo 16.4.0 is released:

```bash
# 1. Create new release branch
git checkout tags/16.4.0
git checkout -b patches/16.4.0

# 2. Test old patches
for patch in ../patches/16.3.0/local/patches/*.patch; do
  patch --dry-run -p1 < "$patch" || echo "NEEDS ADAPTION: $patch"
done

# 3. For patches that don't apply:
#    - Check out feature branch
#    - Cherry-pick, adapt for 16.4.0
#    - Generate new patch on patches/16.4.0

# 4. Commit
git add local/patches/
git commit -m "Adapt patches for Piwigo 16.4.0"
```

---

## Troubleshooting

### Cherry-pick conflicts

```bash
# If cherry-pick fails:
git cherry-pick --abort

# Manually resolve:
git diff feature/2534-menubar-hook -- <conflicted-file>
# Edit the file manually
# Test changes
git add <file>
git commit -m "Adapt <change> for 16.3.0"
```

### Patch doesn't apply

```bash
# Check what changed on master
git diff tags/16.3.0..master -- admin/admin.php

# Regenerate patch with more context if needed
git format-patch tags/16.3.0 --unified=4 -o local/patches/
```

### Release files were modified

```bash
# Restore release files to pristine state
git checkout tags/16.3.0 -- admin/ include/ language/ themes/default/

# Keep only local/patches/ changes
git add admin/ include/ language/ themes/default/
git commit -m "Restore release files to pristine state"
```

---

Last updated: 2026-03-31
