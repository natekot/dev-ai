---
mode: 'agent'
description: 'Resolve merge conflicts in the working tree'
tools: ['terminal']
---
Find conflicted files (`git diff --name-only --diff-filter=U`). For each file, read the conflict markers and understand both sides. If intent is clear, resolve it. If ambiguous, show the developer both sides in a clean summary and ask which version to keep (or how to combine them). Stage each resolved file. After all files are done, verify no conflicts remain with `git diff --check`.
