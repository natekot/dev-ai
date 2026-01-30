---
name: ship-staged
description: Commit only staged changes and push to remote. Use when committing only already-staged changes, pushing staged work, or shipping a partial set of changes.
---

# Ship Staged Changes

## Workflow

1. Commit only already-staged changes using conventional commit format (feat, fix, chore, docs, refactor, test)
2. Write a concise commit message based on the staged diff
3. Push to the current branch's upstream
4. Do not add any unstaged files
