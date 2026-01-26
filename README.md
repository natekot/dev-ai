# GitHub Copilot Prompts & Instructions

A collection of reusable GitHub Copilot prompts and language-specific instructions for common development tasks. Install once and use across all your projects.

## Quick Start

```bash
# Install to your project
./install.sh /path/to/your/project

# Or install to current directory
./install.sh
```

## What Gets Installed

### Prompts
| File | Location | Purpose |
|------|----------|---------|
| `review.prompt.md` | `.github/prompts/global/` | Code review prompt |
| `test.prompt.md` | `.github/prompts/global/` | Test generation prompt |
| `explain.prompt.md` | `.github/prompts/global/` | Code explanation prompt |
| `commit-and-push.prompt.md` | `.github/prompts/global/` | Commit workflow prompt |

### Instructions (Language-Specific)
| File | Applies To | Purpose |
|------|------------|---------|
| `copilot-instructions.md` | All files | Global token efficiency guidelines |
| `c.instructions.md` | `*.c`, `*.h` | C language + K&R style |
| `python.instructions.md` | `*.py` | Python guidelines |
| `bash.instructions.md` | `*.sh`, `*.bash` | Bash/Shell guidelines |
| `testing.instructions.md` | `test_*.py`, `*_test.c`, etc. | Testing patterns |
| `security.instructions.md` | All files | Security guidelines |

## Usage After Installation

In VS Code Copilot Chat, invoke prompts using the `/` syntax:

```
/global/review examples/sample.py
/global/test examples/sample.py
/global/explain examples/sample.py
/global/commit-and-push
```

## Managing Installations

```bash
./install.sh --instructions       # Install only instructions (no prompts)
./install.sh --force              # Force overwrite existing files
./install.sh --uninstall          # Remove installed files
./install.sh --dry-run            # Preview what would be installed
```

## Project Structure

```
├── install.sh                     # Installation script
├── README.md                      # This file
│
├── prompts/                       # Copilot prompts (installable)
│   ├── review.prompt.md           # Code review
│   ├── test.prompt.md             # Test generation
│   ├── explain.prompt.md          # Code explanation
│   └── commit-and-push.prompt.md  # Commit workflow
│
├── instructions/                  # Copilot instructions (installable)
│   ├── copilot-instructions.md    # Global (token efficiency)
│   ├── c.instructions.md          # C language + K&R style
│   ├── python.instructions.md     # Python guidelines
│   ├── bash.instructions.md       # Bash/Shell guidelines
│   ├── testing.instructions.md    # Testing patterns
│   └── security.instructions.md   # Security guidelines
│
├── examples/                      # Demo files
│   └── sample.py
│
└── .github/                       # This repo's Copilot configs
    ├── copilot-instructions.md    # Global instructions
    ├── instructions/              # Language-specific instructions
    │   └── *.instructions.md
    └── prompts/
        └── *.prompt.md            # Local prompts
```

### Installation Target Structure

When you run `./install.sh /path/to/repo`, files are installed to:

```
your-repo/
├── .gitignore                     # Updated with installed paths
└── .github/
    ├── copilot-instructions.md    # Global instructions
    ├── instructions/              # Language-specific instructions
    │   ├── c.instructions.md
    │   ├── python.instructions.md
    │   ├── bash.instructions.md
    │   ├── testing.instructions.md
    │   └── security.instructions.md
    └── prompts/
        └── global/                # Installed prompts
            ├── review.prompt.md
            ├── test.prompt.md
            ├── explain.prompt.md
            └── commit-and-push.prompt.md
```

The `global/` subdirectory ensures installed prompts coexist with your repo-specific prompts without conflicts. Instructions apply automatically based on file patterns in their `applyTo` frontmatter.

Installed paths are automatically added to your project's `.gitignore` to avoid committing them.

## Available Prompts

### `/global/review`
Performs a comprehensive code review checking for:
- Code quality issues
- Potential bugs
- Security concerns
- Readability and maintainability

### `/global/test`
Generates tests for your code:
- Uses pytest as the testing framework
- Includes happy path and edge case tests
- Creates descriptive test names
- Mocks external dependencies

### `/global/explain`
Explains code with:
- High-level overview
- Step-by-step breakdown of complex logic
- Non-obvious patterns and decisions
- Potential gotchas and edge cases

### `/global/commit-and-push`
Guides you through committing changes:
- Reviews staged changes
- Suggests commit message
- Handles the commit workflow

## Copilot Chat Participants

Type `@` in Copilot Chat to access specialized participants:

| Participant | Purpose | Example |
|-------------|---------|---------|
| `@workspace` | Codebase context | `@workspace how is authentication implemented?` |
| `@terminal` | Terminal/shell expertise | `@terminal list the 5 largest files here` |
| `@vscode` | VS Code settings and features | `@vscode how to enable word wrapping?` |
| `@github` | GitHub features and web search | `@github what are my open PRs?` |

## Further Reading

- [GitHub Copilot Customization](https://docs.github.com/en/copilot/customizing-copilot)
- [GitHub Copilot Prompt Files](https://docs.github.com/en/copilot/tutorials/customization-library/prompt-files)
- [Asking GitHub Copilot Questions in Your IDE](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
