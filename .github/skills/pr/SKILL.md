---
name: pr
description: Create a pull request with a generated description. Use when creating pull requests, submitting work for review, or opening PRs against the default branch.
---

# Create Pull Request

## Workflow

1. Compare the current branch against the default branch
2. Read the commit log and diff to understand all changes
3. Generate a PR title using conventional commit style (feat, fix, chore, docs, refactor, test)
4. Generate a structured description with a summary, list of changes, and test plan
5. Create the PR using `gh pr create`
