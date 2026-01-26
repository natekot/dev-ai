---
applyTo: "**/*.sh,**/*.bash"
---

# Bash/Shell Instructions

- Start with `#!/bin/bash` or `#!/usr/bin/env bash`
- Use `set -e` (exit on error) by default
- Quote variables: `"$var"` not `$var`
- Use `[[ ]]` over `[ ]` for conditionals
- Prefer `$(command)` over backticks
- Use functions for reusable logic
- `UPPER_CASE` for constants, `lower_case` for locals
