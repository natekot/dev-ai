# GitHub Copilot + Claude Code Intersection Sandbox

This project demonstrates the **shared concepts** between GitHub Copilot and Claude Code customization systems. Both tools support similar patterns for customization, just with different syntax and file locations.

## Key Intersection Points

| Concept | GitHub Copilot | Claude Code |
|---------|---------------|-------------|
| Slash commands | `.github/prompts/*.prompt.md` | `.claude/commands/*.md` |
| Project guidance | `.github/copilot/instructions.md` | `CLAUDE.md` |
| Agents/Skills | `agents/*.agent.md` | Agent skills in settings |
| MCP integration | MCP server config | MCP server config |
| Hooks | `.github/hooks/*.json` | `.claude/settings.json` hooks |

## Project Structure

```
dev-ai/
├── README.md                      # This file
├── CLAUDE.md                      # Claude Code project guidance
├── .github/
│   ├── copilot/
│   │   └── instructions.md        # Copilot project instructions
│   ├── prompts/                   # Copilot prompt files
│   │   ├── review.prompt.md
│   │   ├── test.prompt.md
│   │   └── explain.prompt.md
│   └── hooks/
│       ├── security.json          # Copilot hooks configuration
│       └── scripts/
│           ├── validate-command.sh   # Block dangerous commands
│           └── audit-log.sh          # Log tool executions
├── .claude/
│   ├── commands/
│   │   ├── review.md              # Code review command
│   │   ├── test.md                # Generate tests command
│   │   └── explain.md             # Explain code command
│   ├── settings.json              # Claude Code settings (including hooks)
│   └── hooks/
│       ├── validate-command.sh    # Block dangerous commands
│       ├── format-file.sh         # Auto-format on write
│       └── audit-log.sh           # Log tool executions
└── examples/
    └── sample.py                  # Sample code to demo against
```

## Using This Sandbox

### With Claude Code

1. **Project Guidance**: Claude Code automatically reads `CLAUDE.md` for project context
2. **Skills**: Use `/review`, `/test`, or `/explain` followed by a file path
3. **Example**:
   ```
   /review examples/sample.py
   ```

### With GitHub Copilot

1. **Project Instructions**: Copilot reads `.github/copilot/instructions.md` automatically
2. **Prompts**: Invoke prompts in Copilot Chat using `/prompt-name` syntax
3. **Example**:
   ```
   /review examples/sample.py
   ```

> **Note on `@` vs `/` syntax:**
> - `/command` invokes prompt files (e.g., `/review` runs `.github/prompts/review.prompt.md`)
> - `@participant` provides context (e.g., `@workspace` gives workspace context, `@terminal` gives terminal output)

### Copilot Chat Participants (`@` syntax)

Chat participants are domain experts that provide specialized context. Type `@` in Copilot Chat to see all available participants.

#### Built-in Participants

| Participant | Purpose | Example |
|-------------|---------|---------|
| `@workspace` | Codebase context—project structure, architecture, implementation details | `@workspace how is authentication implemented?` |
| `@terminal` | Terminal/shell expertise—commands, buffer contents, CLI help | `@terminal list the 5 largest files here` |
| `@vscode` | VS Code knowledge—settings, keybindings, extensions, APIs | `@vscode how to enable word wrapping?` |
| `@github` | GitHub features—PRs, issues, repos, plus web search via `#web` | `@github what are my open PRs?` |

#### `@workspace` (Most Common)

Provides context about your entire codebase:
```
@workspace where are API routes defined?
@workspace explain the project structure
@workspace how does error handling work?
```

#### `@terminal`

Knows about shell commands and terminal contents:
```
@terminal how do I find all .py files?
@terminal /explain    # explains last command
@terminal what does this error mean?
```

#### `@vscode`

Expert on VS Code itself:
```
@vscode what's the shortcut for command palette?
@vscode how do I create a custom snippet?
@vscode configure auto-save on focus change
```

#### `@github`

Accesses GitHub data and web search:
```
@github show recent merged PRs from @username
@github what issues are assigned to me?
@github #web what's the latest version of Node.js?
```

#### IDE Variations

| Participant | VS Code | Visual Studio | JetBrains |
|-------------|---------|---------------|-----------|
| `@workspace` | Yes | Yes | `@project` |
| `@terminal` | Yes | Yes | Limited |
| `@vscode` | Yes | `@visualstudio` | — |
| `@github` | Yes | Yes | Yes |

> **Tip:** Ask `@github What skills are available?` to discover all GitHub-specific capabilities.

---

## The "Write Once, Adapt to Both" Pattern

The key insight is that both tools support the same conceptual patterns:

### 1. Project-Level Instructions
- **Purpose**: Provide context about coding standards, architecture, and preferences
- **Copilot**: `.github/copilot/instructions.md`
- **Claude Code**: `CLAUDE.md`

### 2. Reusable Commands/Prompts
- **Purpose**: Create consistent, repeatable workflows
- **Copilot**: `.github/prompts/*.prompt.md` with YAML frontmatter, invoked via `/prompt-name`
- **Claude Code**: `.claude/commands/*.md` with `$ARGUMENTS` placeholder

### 3. Custom Agents/Skills
- **Purpose**: Specialized assistants for specific tasks
- **Copilot**: `agents/*.agent.md`
- **Claude Code**: Configured via settings or MCP

## Comparison: Same Command, Different Syntax

### Code Review Command

**Claude Code** (`.claude/commands/review.md`):
```markdown
Review the code in $ARGUMENTS for:
- Code quality issues
- Potential bugs
...
```

**GitHub Copilot** (`.github/prompts/review.prompt.md`):
```markdown
---
mode: 'agent'
description: 'Review code for quality and issues'
---
Review the provided code for:
- Code quality issues
- Potential bugs
...
```

## Try It Out

1. Open `examples/sample.py` to see sample code
2. In Claude Code: `/review examples/sample.py`
3. In Copilot Chat: `/review` then provide `examples/sample.py` when prompted

Both tools will provide similar code review output based on their respective prompts.

---

## Hooks: Extending Agent Behavior

Both tools support hooks—shell commands that execute at strategic points during agent workflows. This enables security policies, audit logging, and custom automation.

### Hook Types Comparison

| Hook Event | GitHub Copilot | Claude Code |
|------------|---------------|-------------|
| Before tool execution | `preToolUse` | `PreToolUse` |
| After tool execution | `postToolUse` | `PostToolUse` |
| Session start | `sessionStart` | — |
| Session end | `sessionEnd` | — |
| On user prompt | `userPromptSubmitted` | `Notification` |
| On error | `errorOccurred` | — |

### GitHub Copilot Hooks

Location: `.github/hooks/*.json`

**Example: Block dangerous git commands**

```json
{
  "version": "1.0",
  "hooks": {
    "preToolUse": [
      {
        "type": "command",
        "commands": {
          "bash": ".github/hooks/scripts/block-force-push.sh"
        },
        "timeout": 30000,
        "env": {
          "BLOCKED_PATTERNS": "push --force|reset --hard|clean -fd"
        }
      }
    ]
  }
}
```

**Example: Audit logging**

```json
{
  "version": "1.0",
  "hooks": {
    "postToolUse": [
      {
        "type": "command",
        "commands": {
          "bash": "echo \"$(date): Tool executed\" >> .github/hooks/audit.log"
        },
        "timeout": 5000
      }
    ],
    "sessionStart": [
      {
        "type": "command",
        "commands": {
          "bash": "echo \"Session started at $(date)\" >> .github/hooks/audit.log"
        }
      }
    ]
  }
}
```

### Claude Code Hooks

Location: `.claude/settings.json`

**Example: Block dangerous commands**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '[[ ! \"$TOOL_INPUT\" =~ (rm -rf|sudo|chmod 777) ]]'",
            "description": "Block dangerous shell commands"
          }
        ]
      }
    ]
  }
}
```

**Example: Auto-format on file write**

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "prettier --write \"$TOOL_INPUT_PATH\" 2>/dev/null || true",
            "description": "Auto-format written files"
          }
        ]
      }
    ]
  }
}
```

**Example: Require confirmation for destructive operations**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash(git push*)",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'About to push to remote repository'",
            "description": "Notify before git push"
          }
        ]
      }
    ]
  }
}
```

### Hooks Capabilities Summary

| Capability | Copilot | Claude Code |
|------------|---------|-------------|
| Block tool execution | Yes (`preToolUse` exit code) | Yes (`PreToolUse` exit code) |
| Modify environment | Yes (env vars) | Yes (env vars) |
| Audit/logging | Yes | Yes |
| Platform-specific commands | Yes (bash/powershell) | Yes (shell commands) |
| Timeout configuration | Yes | Yes |
| Tool-specific matching | Via script logic | Built-in matcher syntax |

---

## Further Reading

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [GitHub Copilot Prompt Files](https://docs.github.com/en/copilot/tutorials/customization-library/prompt-files)
- [GitHub Copilot Hooks](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-hooks)
- [GitHub Copilot in VS Code Cheat Sheet](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features)
- [Asking GitHub Copilot Questions in Your IDE](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
