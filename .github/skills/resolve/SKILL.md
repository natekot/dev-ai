---
name: resolve
description: Resolve merge conflicts in the working tree. Use when encountering merge conflicts, rebase conflicts, or cherry-pick conflicts that need resolution.
---

# Resolve Merge Conflicts

## Workflow

1. Find conflicted files using `git diff --name-only --diff-filter=U`
2. For each conflicted file, read the conflict markers and understand both sides
3. If the intent is clear, resolve the conflict directly
4. If ambiguous, show both sides in a clean summary and ask which version to keep or how to combine them
5. Stage each resolved file with `git add`
6. After all files are resolved, verify no conflicts remain with `git diff --check`
