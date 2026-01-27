# GitHub Copilot Prompts & Instructions

A collection of reusable GitHub Copilot prompts and language-specific instructions for common development tasks. Install once and use across all your projects.

## Quick Start

### Linux / macOS

```bash
./install.sh /path/to/your/project
```

### Windows

```cmd
install.bat C:\path\to\your\project
```

Note: The Windows installer creates file symlinks, which requires Developer Mode enabled (Windows 10+) or Administrator privileges.

## What Gets Installed

Individual symlinks are created for each prompt and instruction file:

### Prompts
| File | Location | Purpose |
|------|----------|---------|
| `review.prompt.md` | `.github/prompts/` | Code review prompt |
| `test.prompt.md` | `.github/prompts/` | Test generation prompt |
| `explain.prompt.md` | `.github/prompts/` | Code explanation prompt |
| `commit-and-push.prompt.md` | `.github/prompts/` | Commit workflow prompt |

### Instructions (Language-Specific)
| File | Applies To | Purpose |
|------|------------|---------|
| `global.instructions.md` | All files (`**`) | Global token efficiency guidelines |
| `c.instructions.md` | `*.c`, `*.h` | C language + K&R style |
| `python.instructions.md` | `*.py` | Python guidelines |
| `bash.instructions.md` | `*.sh`, `*.bash` | Bash/Shell guidelines |
| `testing.instructions.md` | `test_*.py`, `*_test.c`, etc. | Testing patterns |
| `security.instructions.md` | All files | Security guidelines |

## Usage After Installation

In VS Code Copilot Chat, invoke prompts using the `/` syntax:

```
/review examples/sample.py
/test examples/sample.py
/explain examples/sample.py
/commit-and-push
```

## Managing Installations

```bash
# Linux / macOS
./install.sh /path/to/project --force     # Force overwrite existing files
./install.sh /path/to/project --dry-run   # Preview what would be installed
./install.sh --uninstall /path/to/project # Remove installed symlinks

# Windows
install.bat C:\path\to\project --force     # Force overwrite existing
install.bat C:\path\to\project --dry-run   # Preview what would be installed
install.bat --uninstall C:\path\to\project # Remove installed junctions
```

## Project Structure

```
├── install.sh                     # Installation script (Linux/macOS)
├── install.bat                    # Installation script (Windows)
├── README.md                      # This file
├── examples/                      # Demo files
│   └── sample.py
│
└── .github/                       # Source prompts & instructions
    ├── instructions/              # All instructions (including global)
    │   ├── global.instructions.md
    │   ├── c.instructions.md
    │   ├── python.instructions.md
    │   ├── bash.instructions.md
    │   ├── testing.instructions.md
    │   └── security.instructions.md
    └── prompts/
        ├── review.prompt.md
        ├── test.prompt.md
        ├── explain.prompt.md
        └── commit-and-push.prompt.md
```

### Installation Target Structure

When you run the installer, individual file symlinks are created:

```
your-repo/.github/
├── instructions/
│   ├── bash.instructions.md       ->  dev-ai/.github/instructions/bash.instructions.md
│   ├── python.instructions.md     ->  dev-ai/.github/instructions/python.instructions.md
│   ├── ...                        (other instruction symlinks)
│   └── my.instructions.md         (your repo's own instructions, untouched)
└── prompts/
    ├── review.prompt.md           ->  dev-ai/.github/prompts/review.prompt.md
    ├── test.prompt.md             ->  dev-ai/.github/prompts/test.prompt.md
    ├── ...                        (other prompt symlinks)
    └── my-prompt.prompt.md        (your repo's own prompts, untouched)
```

If a file already exists in your project, it will be skipped (use `--force` to overwrite). Instructions apply automatically based on file patterns in their `applyTo` frontmatter.

## Available Prompts

### `/review`
Performs a comprehensive code review checking for:
- Code quality issues
- Potential bugs
- Security concerns
- Readability and maintainability

### `/test`
Generates tests for your code:
- Uses pytest as the testing framework
- Includes happy path and edge case tests
- Creates descriptive test names
- Mocks external dependencies

### `/explain`
Explains code with:
- High-level overview
- Step-by-step breakdown of complex logic
- Non-obvious patterns and decisions
- Potential gotchas and edge cases

### `/commit-and-push`
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
